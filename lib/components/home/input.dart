import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:labhouse/services/ai.dart';
import 'package:labhouse/services/theme.dart';
import 'package:remixicon/remixicon.dart';
import 'package:zo_animated_border/widget/zo_snake_border.dart';

class GenerateRankingInput extends StatefulWidget {
  const GenerateRankingInput({super.key});

  @override
  State<GenerateRankingInput> createState() => _GenerateRankingInputState();
}

class _GenerateRankingInputState extends State<GenerateRankingInput> {
  FocusNode focusNode = FocusNode();
  TextEditingController controller = TextEditingController();
  bool loading = false;

  generate() async {
    loading = true;
    setState(() {});
    final res = await generateRanking(controller.text);
    if (res) controller.clear();

    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.mediaQuery.size.width - 32,
      child: ZoSnakeBorder(
        duration: 3,
        snakeHeadColor: aiColors.first,
        snakeTailColor: aiColors[1],
        snakeTrackColor: aiColors.last,
        borderWidth: focusNode.hasFocus || loading ? 5 : 0,
        borderRadius: BorderRadius.circular(10),
        child: TextField(
          focusNode: focusNode,
          controller: controller,
          enabled: !loading,
          onTapOutside: (event) => focusNode.unfocus(),
          onSubmitted: (value) => generate(),
          textAlignVertical: TextAlignVertical.center,
          strutStyle: StrutStyle.fromTextStyle(const TextStyle(height: 1)),
          style: const TextStyle(fontSize: 16, height: 1, leadingDistribution: TextLeadingDistribution.even),
          cursorHeight: 30,
          decoration: InputDecoration(
            hintText: 'Create a Ranking',
            hintStyle: const TextStyle(fontSize: 14),
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            prefixIcon: Icon(Remix.sparkling_2_fill),
            suffixIconConstraints: const BoxConstraints(maxWidth: 34, maxHeight: 24),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 10),
              child:
                  loading
                      ? CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary, strokeWidth: 2)
                      : IconButton(
                        icon: Icon(controller.text.isEmpty ? Remix.send_plane_2_line : Remix.send_plane_2_fill),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.all(0),
                        onPressed: controller.text.isEmpty ? null : generate,
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
