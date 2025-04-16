import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:labhouse/services/theme.dart';

Future<void> showGetDialog({required Widget child, bool dismissible = true, useSafeArea = true}) async {
  await Get.dialog(child, barrierDismissible: dismissible, useSafeArea: useSafeArea);
  return;
}

showGetSnackBar({
  required String message,
  String? title,
  Color? backgroundColor,
  Duration? duration,
  Widget? button,
  bool isDismissible = true,
}) => Get.rawSnackbar(
  titleText: title != null ? Text(title, style: Theme.of(Get.context!).textTheme.titleMedium) : null,
  messageText: Text(message, style: Theme.of(Get.context!).textTheme.titleSmall),
  duration: duration ?? 4.seconds,
  backgroundColor: backgroundColor ?? Theme.of(Get.context!).colorScheme.errorContainer,
  borderRadius: themeBorderRadius,
  forwardAnimationCurve: Curves.easeInOutQuint,
  reverseAnimationCurve: Curves.easeInOutQuint,
  isDismissible: isDismissible,
  margin: const EdgeInsets.all(12),
  mainButton: button,
);
