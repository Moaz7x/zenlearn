import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A custom animated checkbox with glow and sparkle effects.
class CustomCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? borderColor;
  final Color? glowColor;
  final Color? sparkleColor;
  final double size;

  final Duration animationDuration;
  const CustomCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.borderColor,
    this.glowColor,
    this.sparkleColor,
    this.size = 24.0,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomCheckboxState createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _sparkleAnimation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Use standard theme access
    final activeColor = widget.activeColor ?? theme.colorScheme.primary; // Use theme color
    final borderColor = widget.borderColor ?? Colors.grey;
    final glowColor = widget.glowColor ?? activeColor.withOpacity(0.3);
    final sparkleColor = widget.sparkleColor ?? Colors.yellow;

    return GestureDetector(
      onTap: _handleTap,
      child: Semantics(
        label: "Custom Checkbox",
        checked: widget.value,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Glow effect
                  if (widget.value)
                    Container(
                      width: widget.size * 1.01,
                      height: widget.size * 1.01,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: glowColor.withOpacity(_glowAnimation.value),
                      ),
                    ),

                  // Checkbox container
                  AnimatedContainer(
                    duration: widget.animationDuration,
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.value ? activeColor : borderColor,
                        width: 2,
                      ),
                      color: widget.value ? activeColor : Colors.transparent,
                    ),
                    child: widget.value
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),

                  // Sparkle effect
                  if (widget.value)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Transform.rotate(
                        angle: _sparkleAnimation.value * 2 * math.pi,
                        child: Icon(
                          Icons.star,
                          size: widget.size * 0.5,
                          color: sparkleColor.withOpacity(_sparkleAnimation.value),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant CustomCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      widget.value ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.value) _controller.value = 1.0;
  }

  void _handleTap() {
    widget.onChanged?.call(!widget.value);
  }
}
