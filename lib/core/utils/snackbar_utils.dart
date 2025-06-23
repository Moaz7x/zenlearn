import 'package:flutter/widgets.dart';

import '../widgets/cusrom_glass_snackbar.dart';

extension GlassToast on BuildContext {
  void showGlassSnackBar({
    required String message,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    GlassSnackBar.show(
      this,
      message: message,
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
      backgroundColor: backgroundColor,
      textColor: textColor,
      duration: duration,
    );
  }
}
