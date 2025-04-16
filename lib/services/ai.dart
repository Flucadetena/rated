import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:labhouse/components/popups/popups.dart';
import 'package:labhouse/controllers/auth.dart';
import 'package:labhouse/models/ai.dart';
import 'package:labhouse/models/item.dart';
import 'package:labhouse/models/ranking.dart';
import 'package:labhouse/prompts/system_instructions.dart';
import 'package:labhouse/services/firebase/references.dart';
import 'package:labhouse/services/firebase/retrieve.dart';
import 'package:labhouse/services/helpers.dart';

Future<bool> generateRanking(String request) async {
  try {
    final model = FirebaseVertexAI.instanceFor(
      auth: FirebaseAuth.instance,
    ).generativeModel(model: 'gemini-2.0-flash', systemInstruction: defaultSystemInstructions);

    final chat = model.startGeminiChat(schema: rankingSchema);
    chat.tools = [
      Tool.functionDeclarations([
        FunctionDeclaration(
          'google_search',
          '',
          parameters: {
            "type": Schema.object(properties: {"mode": Schema.string()}),
          },
        ),
      ]),
    ];

    final res = await promptWithRetries(() => chat.oneTimeGeneration([Content.text(request)]));
    if (res == null) {
      return false;
    }

    if (res.text case String text) {
      final json = jsonDecode(text);

      List<(Ranking, List<RankingItem>)> rankings = [];
      for (var ranking in json) {
        if (ranking
            case Map<String, dynamic> jsonRank &&
                {'name': String _, 'description': String _, 'cover': String _, 'category': String _, 'items': List _}) {
          List<RankingItem> items = [];
          for (var item in jsonRank['items']) {
            if (item
                case Map<String, dynamic> jsonItem &&
                    {
                      'name': String _,
                      'position': num _,
                      'description': String _,
                      'category': String _,
                      'cover': String _,
                      'link': String _,
                      'info': List _,
                    }) {
              items.add(RankingItem.fromPrompt(jsonItem));
            }
          }
          rankings.add((Ranking.fromPrompt(jsonRank), items));
        }
      }

      List<Future<void>> promises = [];

      for (var ranking in rankings) {
        final (rank, items) = ranking;
        promises.add(FireDocument(refUserRanking(AuthDetails.currentUser!.uid, rank.id), rank).upSet);
        for (var item in items) {
          promises.add(FireDocument(refRankingItem(AuthDetails.currentUser!.uid, rank.id, item.id), item).upSet);
        }
      }
      await Future.wait(promises);
    }
    return true;
  } catch (err, stack) {
    crashError(err, 'Error generating rankings', stack: stack);
    showGetSnackBar(message: 'Something happen generating the Rankings, please try again 🫠');
    return false;
  }
}

final rankingSchema = Schema.array(
  items: Schema.object(
    properties: {
      "name": Schema.string(),
      "description": Schema.string(),
      "category": Schema.string(),
      "cover": Schema.string(),
      "items": Schema.array(
        items: Schema.object(
          properties: {
            "name": Schema.string(),
            "description": Schema.string(),
            "category": Schema.string(),
            "cover": Schema.string(),
            "position": Schema.number(),
            "link": Schema.string(),
            "info": Schema.array(items: Schema.object(properties: {"key": Schema.string(), "value": Schema.string()})),
          },
        ),
      ),
    },
  ),
);
