// app_text_field\n// Created: 2025-05-19\n\n
import 'package:flutter/material.dart';

/// A custom input field with a split animated border on focus.
class CustomInput extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final Color? topBorderColor;
  final Color? bottomBorderColor;
  final double borderWidth;
  final double borderRadius;
  final Duration animationDuration;
  final int? maxLines;
  final int? minLines;
  const CustomInput({
    super.key,
    required this.hintText,
    required this.controller,
    this.topBorderColor,
    this.bottomBorderColor,
    this.borderWidth = 2.0,
    this.borderRadius = 12.0,
    this.maxLines,
    this.minLines,
    this.animationDuration = const Duration(milliseconds: 1200),
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bottomAnimation;
  late final Animation<double> _topAnimation;
  late final FocusNode _focusNode;

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder baseBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.grey, width: 1),
      borderRadius: BorderRadius.circular(widget.borderRadius),
    );

    return Stack(
      children: [
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.tertiary), // Use theme color
            border: baseBorder,
            enabledBorder: baseBorder,
            focusedBorder: baseBorder,
            // contentPadding:
            // const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _SplitOutlinePainter(
                // Use the local painter
                bottomAnimation: _bottomAnimation,
                topAnimation: _topAnimation,
                border: baseBorder,
                bottomBorderColor: widget.bottomBorderColor ??
                    Theme.of(context).colorScheme.secondary, // Use theme color
                topBorderColor: widget.topBorderColor ??
                    Theme.of(context).colorScheme.primary, // Use theme color
                borderWidth: widget.borderWidth,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _bottomAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    );

    _topAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    );

    _focusNode = FocusNode()
      ..addListener(() {
        if (_focusNode.hasFocus) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      });
  }
}

// Duplicated SplitOutlinePainter for CustomInput
// Consider moving this to a shared utility file if used by more widgets
class _SplitOutlinePainter extends CustomPainter {
  final Animation<double> bottomAnimation;
  final Animation<double> topAnimation;
  final OutlineInputBorder border;
  final Color bottomBorderColor;
  final Color topBorderColor;
  final double borderWidth;
  _SplitOutlinePainter({
    required this.bottomAnimation,
    required this.topAnimation,
    required this.border,
    required this.bottomBorderColor,
    required this.topBorderColor,
    required this.borderWidth,
  }) : super(repaint: Listenable.merge([bottomAnimation, topAnimation]));

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Path fullOutline = border.getOuterPath(rect, textDirection: TextDirection.ltr);

    final metrics = fullOutline.computeMetrics();
    final Path bottomPath = Path();
    final Path topPath = Path();

    for (final metric in metrics) {
      final double halfLength = metric.length / 2;
      final double bottomDrawLength = halfLength * bottomAnimation.value;
      bottomPath.addPath(metric.extractPath(0, bottomDrawLength), Offset.zero);

      final double topDrawLength = halfLength * topAnimation.value;
      topPath.addPath(metric.extractPath(halfLength, halfLength + topDrawLength), Offset.zero);
    }

    final Paint bottomPaint = Paint()
      ..color = bottomBorderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    final Paint topPaint = Paint()
      ..color = topBorderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    canvas.drawPath(bottomPath, bottomPaint);
    canvas.drawPath(topPath, topPaint);
  }

  @override
  bool shouldRepaint(covariant _SplitOutlinePainter oldDelegate) {
    return oldDelegate.bottomAnimation.value != bottomAnimation.value ||
        oldDelegate.topAnimation.value != topAnimation.value ||
        oldDelegate.bottomBorderColor != bottomBorderColor ||
        oldDelegate.topBorderColor != topBorderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}
