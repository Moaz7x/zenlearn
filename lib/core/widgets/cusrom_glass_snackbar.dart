import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GlassSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bgColor = backgroundColor ??
        theme.snackBarTheme.backgroundColor ??
        colorScheme.surface.withOpacity(0.5);
    final contentColor =
        textColor ?? theme.snackBarTheme.contentTextStyle?.color ?? colorScheme.onSurface;

    final snackBar = SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      content: AppTheme.glassContainer(
        borderRadius: 12,
        blur: 20,
        opacity: 0.3,
        color: bgColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(icon, color: contentColor),
                ),
              Expanded(
                child: Text(
                  message,
                  style: theme.snackBarTheme.contentTextStyle?.copyWith(color: contentColor),
                ),
              ),
              if (actionLabel != null && onAction != null)
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: contentColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: onAction,
                  child: Text(actionLabel),
                ),
            ],
          ),
        ),
      ),
    );

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
