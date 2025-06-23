import 'package:flutter/material.dart';

class CustomLinearProgressIndicator extends StatelessWidget {
  final double value;
  final Color backgroundColor;
  final Color progressColor;
  final double height;
  final BorderRadius borderRadius;
  final Duration duration;

  const CustomLinearProgressIndicator({
    super.key,
    required this.value,
    this.backgroundColor = Colors.grey,
    this.progressColor = Colors.blue,
    this.height = 10.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(5.0)),
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: borderRadius,
          child: Container(
            height: height,
            width: constraints.maxWidth,
            color: backgroundColor,
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: duration,
                  curve: Curves.easeInOut,
                  width: constraints.maxWidth * value.clamp(0.0, 1.0),
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: borderRadius,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
