import 'package:collection/collection.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:labhouse/services/helpers.dart';

///* SELF NOTE: Reason for this class. The current [ChatSession] from VertexAI is not flexible and stable enough
/// There are a couple of pull requests and fixed awaiting:
/// - The chat history is using a temporary solution until they fix it on a new release. There is a pull request open [https://github.com/firebase/flutterfire/pull/13040]
/// - Also there is a problem when the content is blocked, that adds a 'null' role value to the history and breaks the chat. Awaiting pull request: [https://github.com/google-gemini/generative-ai-dart/pull/198]
///
///* Create Issue with proposals form some of the implementations here after the challenge with time. Also create separated pull requests to make the dart package behave more like the node one.

/// Enum representing the currently supported roles by Gemini.
/// The generation demands the only roles present in the `prompt` (history + message) must be `user` and/or `model`.
///
/// The system role must only be use to init the model.
///
/// NOTE: If the model is ignoring the systemInstructions, we could implement a conversion on the [_validateHistory] method from the
/// [GeminiChatSession] class to reinterpret the system role as a dynamic between user and model at the top.
enum GeminiContentRole {
  user('user'),
  model('model'),
  functionResponse('functionResponse'),
  functionCall('functionCall'),
  system('system');

  final String name;
  const GeminiContentRole(this.name);

  static GeminiContentRole fromString(String role) => switch (role) {
    'user' => user,
    'model' => model,
    'system' => system,
    'functionResponse' => functionResponse,
    'functionCall' => functionCall,
    _ => throw Exception('Invalid role: $role'),
  };
}

final class GeminiChatSession {
  List<Tool>? _tools;
  String? _context;

  final List<SafetySetting> _safetySettings = [
    SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high, null),
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high, null),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high, null),
    SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high, null),
  ];
  late final GenerationConfig _generationConfig;

  GeminiChatSession._(this._generateContent, Schema? _schema, List<Tool>? tools) : _tools = tools {
    _generationConfig = GenerationConfig(
      temperature: 1,
      topP: 0.95,
      topK: 30,
      maxOutputTokens: 8190,
      responseMimeType: "application/json",
      responseSchema: _schema,
    );
  }

  /// The functions that the model can call to generate content.
  set tools(List<Tool>? newTools) {
    _tools = newTools;
  }

  /// This is appended on top of the history. Use it to give the model commands and relevant information that
  /// needs to use for the generation.
  ///
  /// This is mainly use to provide temporary context that you may not use on the next prompt.
  /// It also helps us avoid passing the same data over and over to the model like we need to do in the default [ChatSession] from VertexAI.
  ///
  /// This is not part of the chat history.
  /// Pro Tip: You can use it to pass "start" prompts that you may not want to be reflected on the history.
  set context(String newContext) {
    _context = newContext;
  }

  appendToContext(String newContext) {
    if (_context == null) return context = newContext;

    _context = '$_context $newContext';
  }

  /// Sends [message] to the model as a continuation of the chat [history].
  ///
  /// The final `prompt` send to the model will include: the [context], the [history] and the [message]. In this order.
  ///
  /// Every message sent is a complete new generation, it is not really a chat.
  /// Taking this into account, any changes to: the [context] or the [tools], will be reflected in the next message sent.
  ///
  /// You must await for the generation to finish before sending a new message.
  /// The history does not include the message sent or the response from the model.
  /// You must handle the response and decide if you want to add it to the history or not.
  Future<GenerateContentResponse> sendMessage(Iterable<Content> history) async {
    try {
      final prompt = [if (_context case String context when context.isNotEmpty) Content.text(context), ...history];

      final validated = _validateHistory(prompt);
      final response = await _generateContent(
        validated,
        tools: _tools,
        safetySettings: _safetySettings,
        generationConfig: _generationConfig,
      );

      return response;
    } catch (err) {
      rethrow;
    }
  }

  Future<GenerateContentResponse> oneTimeGeneration(
    List<Content> content, {
    List<Tool>? oneTimeTools,
    ToolConfig? toolConfig,
  }) async {
    final validate = _validateHistory(content);

    final response = await _generateContent(
      validate,
      tools: oneTimeTools,
      toolConfig: toolConfig,
      safetySettings: _safetySettings,
      generationConfig: _generationConfig,
    );

    return response;
  }

  /// Validates the history of chat session contents and returns a list of validated contents.
  ///
  /// The [history] parameter is an iterable of [Content] objects representing the chat session history.
  /// The function performs the following validations:
  /// - The history cannot be empty. If it is, an exception is thrown.
  /// - The first message in the history must be from the user. If it is a model it will be skipped and removed from the history.
  /// - Each content in the history must have a non-null role, which can be either "user" or "model". If the role is null or not one of these values, an exception is thrown.
  /// - Gemini requires for the history to alternate between "user" and "model". Taking this into account, consecutive contents with the same role are merged into a single one.
  ///
  /// The function returns an iterable of [Content] objects representing the validated contents.
  Iterable<Content> _validateHistory(Iterable<Content> history) {
    final List<Content> contents = [];

    if (history.first.role == GeminiContentRole.model.name) {
      history = history.skip(1);
    }

    if (history.isEmpty) {
      throw Exception('The prompt cannot be empty or have the role "model" if there is no history to start with');
    }

    history.forEachIndexed((idx, content) {
      final Content(:role, :parts) = content;

      if (role == GeminiContentRole.system.name) {
        throw Exception('Gemini does not support the role "system" in the history');
      }

      if (idx == 0) return contents.add(content);
      if (role == GeminiContentRole.functionCall.name) {
        return contents.add(Content.model(parts));
      }

      String previousRole = history.elementAt(idx - 1).role!;
      if (role == previousRole) {
        contents.last.parts.addAll(parts);
      } else {
        contents.add(content);
      }
    });

    return contents;
  }

  /// This is just the mapped function from the VertexAI and Google-generativeAI packages.
  /// It is at the bottom of the file to improve readability and understanding of the used functions.
  final Future<GenerateContentResponse> Function(
    Iterable<Content> content, {
    List<Tool>? tools,
    List<SafetySetting>? safetySettings,
    GenerationConfig? generationConfig,
    ToolConfig? toolConfig,
  })
  _generateContent;
}

/// A simple extension, coping the VertexAI and Google-generativeAI packages, to generate content from the [GenerativeModel].
extension GeminiChatSessionExtension on GenerativeModel {
  GeminiChatSession startGeminiChat({List<Content>? history, Schema? schema, List<Tool>? tools}) =>
      GeminiChatSession._(generateContent, schema, tools);
}

/// Retries a GenerationContent request up to 3 times.
/// If the first candidate in the response is blocked due to recitation, safety, or other reasons in
/// all the attempts, the function will return `null`. If any succeed it will return a [GenerateContentResponse].
///
/// The [func] parameter is the Generation function that prompts Mowy. It must return [Future<GenerateContentResponse>].
/// The [retries] parameter specifies the number of retries to attempt. The default value is 1.
/// The max amount of tries is 3. So if [retries] is set to 2 it will only try twice. If set to greater than 3 it will loop endlessly until succeeds
/// or other Generation limits through.
///
/// Any errors that occur during the process will be logged to Crashlytics.
Future<GenerateContentResponse?> promptWithRetries(
  Future<GenerateContentResponse> Function() func, {
  int retries = 1,
}) async {
  try {
    if (retries > 3) throw Exception('Too many retries');

    /// We trim the last as it is the loading message
    GenerateContentResponse response = await func();

    if (response.candidates.isNotEmpty && wasPromptBlocked(response.candidates.first.finishReason)) {
      return await promptWithRetries(func, retries: ++retries);
    }

    return response;
  } catch (e, stack) {
    crashError(e, 'Error getting a response from model after retries', stack: stack);
    return null;
  }
}

bool wasPromptBlocked(FinishReason? reason) =>
    reason == FinishReason.recitation || reason == FinishReason.safety || reason == FinishReason.other;
