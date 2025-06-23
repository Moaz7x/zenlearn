// app_button\n// Created: 2025-05-19\n\n
import 'package:flutter/material.dart';

/// A custom animated button with a split animated border.
class CustomButton extends StatefulWidget {
  /// The text displayed on the button.
  final String text;

  /// Called when the button is tapped.
  final VoidCallback? onPressed;

  /// Called when the button is long-pressed.
  final VoidCallback? onLongPress;

  /// The background color of the button.
  final Color? backgroundColor;

  /// The color for the top half of the animated border.
  final Color? topBorderColor;

  /// The color for the bottom half of the animated border.
  final Color? bottomBorderColor;

  /// The width of the animated border.
  final double borderWidth;

  /// The radius of the button’s corners.
  final double borderRadius;

  /// The text style for the button.
  final TextStyle? textStyle;

  /// The internal padding of the button.
  final EdgeInsetsGeometry padding;

  /// The duration of the border animation.
  final Duration animationDuration;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.onLongPress,
    this.backgroundColor,
    this.topBorderColor,
    this.bottomBorderColor,
    this.borderWidth = 2.0,
    this.borderRadius = 12.0,
    this.textStyle,
    this.padding = const EdgeInsets.all(16),
    this.animationDuration = const Duration(milliseconds: 1200),
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bottomAnimation;
  late final Animation<double> _topAnimation;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = TextStyle(
      color: Theme.of(context).colorScheme.onPrimary, // Use theme color
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
    final textStyle = widget.textStyle ?? defaultTextStyle;

    // Use an OutlineInputBorder as a base shape for the animated border.
    final OutlineInputBorder baseBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent, width: widget.borderWidth),
      borderRadius: BorderRadius.circular(widget.borderRadius),
    );

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      onLongPress: widget.onLongPress,
      child: Stack(
        children: [
          Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? Theme.of(context).colorScheme.primary, // Use theme color
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: Center(child: Text(widget.text, style: textStyle)),
          ),
          // The animated border overlay.
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: SplitOutlinePainter(
                  bottomAnimation: _bottomAnimation,
                  topAnimation: _topAnimation,
                  border: baseBorder,
                  bottomBorderColor: widget.bottomBorderColor ?? Theme.of(context).colorScheme.secondary, // Use theme color
                  topBorderColor: widget.topBorderColor ?? Theme.of(context).colorScheme.tertiary, // Use theme color
                  borderWidth: widget.borderWidth,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A custom painter that draws a split animated border.
/// It uses two animations to animate the bottom and top halves of the border.
class SplitOutlinePainter extends CustomPainter {
  final Animation<double> bottomAnimation;
  final Animation<double> topAnimation;
  final OutlineInputBorder border;
  final Color bottomBorderColor;
  final Color topBorderColor;
  final double borderWidth;

  SplitOutlinePainter({
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
    final Path fullOutline =
    border.getOuterPath(rect, textDirection: TextDirection.ltr);

    final metrics = fullOutline.computeMetrics();
    final Path bottomPath = Path();
    final Path topPath = Path();

    for (final metric in metrics) {
      final double halfLength = metric.length / 2;
      final double bottomDrawLength = halfLength * bottomAnimation.value;
      bottomPath.addPath(
          metric.extractPath(0, bottomDrawLength), Offset.zero);

      final double topDrawLength = halfLength * topAnimation.value;
      topPath.addPath(
          metric.extractPath(halfLength, halfLength + topDrawLength),
          Offset.zero);
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
  bool shouldRepaint(covariant SplitOutlinePainter oldDelegate) {
    return oldDelegate.bottomAnimation.value != bottomAnimation.value ||
        oldDelegate.topAnimation.value != topAnimation.value ||
        oldDelegate.bottomBorderColor != bottomBorderColor ||
        oldDelegate.topBorderColor != topBorderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}
