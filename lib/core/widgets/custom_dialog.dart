import 'dart:ui';

import 'package:flutter/material.dart';

class GlassDialog extends StatelessWidget {
  final GlassDialogType type;
  final Widget content;
  const GlassDialog({
    super.key,
    required this.content,
    this.type = GlassDialogType.info,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_icon(), size: 48, color: _color()),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: content,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _color() {
    switch (type) {
      case GlassDialogType.error:
        return Colors.redAccent;
      case GlassDialogType.action:
        return Colors.orangeAccent;
      case GlassDialogType.info:
      default:
        return Colors.blueAccent;
    }
  }

  IconData _icon() {
    switch (type) {
      case GlassDialogType.error:
        return Icons.error_rounded;
      case GlassDialogType.action:
        return Icons.warning_amber_rounded;
      case GlassDialogType.info:
      default:
        return Icons.info_outline_rounded;
    }
  }
}

enum GlassDialogType { info, error, action }
