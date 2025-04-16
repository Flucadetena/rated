import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:labhouse/components/welcome/selection.dart';
import 'package:labhouse/controllers/welcome.dart';
import 'package:labhouse/services/theme.dart';
import 'package:zo_animated_border/widget/zo_breathing_border.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WelcomeDetails>(
      init: WelcomeDetails(),
      builder: (details) {
        return SafeArea(
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                spacing: 8,
                children: [
                  AnimatedOpacity(
                    duration: 0.5.seconds,
                    opacity: details.loadingRankings ? 0 : 1,
                    child: AnimatedSwitcher(
                      duration: 1.5.seconds,
                      transitionBuilder: (child, animation) => SizeTransition(sizeFactor: animation, child: child),
                      child: details.loadingRankings ? SizedBox() : WelcomeSelection(),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: ZoBreathingBorder(
                        borderWidth: 10,
                        borderRadius: BorderRadius.circular(500),
                        colors: aiColors,
                        duration: const Duration(seconds: 4),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: details.loadingRankings ? (context.mediaQuery.size.width * 0.5) : 70,
                          ),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Center(
                              child: Text(
                                details.loadingRankings ? details.loadingText : '${details.selected.length}/4',
                                textAlign: TextAlign.center,
                                style: switch (details.selected.length) {
                                  0 => Theme.of(context).textTheme.bodyLarge,
                                  1 => Theme.of(context).textTheme.titleMedium,
                                  2 => Theme.of(context).textTheme.titleLarge,
                                  _ => Theme.of(context).textTheme.headlineMedium,
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
