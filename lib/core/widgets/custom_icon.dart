import 'package:flutter/material.dart';

/// A responsive custom icon from assets.
class CustomIcon extends StatelessWidget {
  final String assetName;
  final double? size;
  final Color? color;
  const CustomIcon.asset(
    this.assetName, {
    super.key,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = size ?? screenWidth * 0.06; // Responsive default size

    return Image.asset(
      assetName,
      width: iconSize,
      height: iconSize,
      color: color,
      fit: BoxFit.contain,
    );
  }
}
