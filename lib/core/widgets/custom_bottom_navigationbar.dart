import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bottomnavbar/navigation_bloc.dart';

part 'bottomnavitem.dart';

class AwesomeBottomNavBar extends StatelessWidget {
  final List<BottomNavItem> items;
  final List<Widget> pages;
  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;
  final double height;
  final double borderRadius;
  final bool showLabels;
  final AnimationType animationType;
  final Duration animationDuration;
  final bool enableHapticFeedback;
  
  const AwesomeBottomNavBar({
    super.key,
    required this.items,
    required this.pages,
    this.backgroundColor = Colors.white,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.grey,
    this.height = 70,
    this.borderRadius = 35,
    this.showLabels = false,
    this.animationType = AnimationType.scale,
    this.animationDuration = const Duration(milliseconds: 300),
    this.enableHapticFeedback = true,
  }) : assert(items.length == pages.length, 'Items and pages must have the same length');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Column(
          children: [
            // Page Content
            Expanded(
              child: IndexedStack(
                index: state.currentIndex,
                children: pages,
              ),
            ),
            // Bottom Navigation Bar
            Container(
              margin: const EdgeInsets.all(16),
              height: height,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = index == state.currentIndex;

                  return Expanded(
                    child: _buildNavItem(
                      context,
                      item,
                      index,
                      isSelected,
                      state.isAnimating,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    BottomNavItem item,
    int index,
    bool isSelected,
    bool isAnimating,
  ) {
    return GestureDetector(
      onTap: () => _handleTap(context, index),
      child: AnimatedContainer(
        duration: animationDuration,
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAnimatedIcon(item, isSelected, isAnimating),
            if (showLabels && item.label != null) ...[
              const SizedBox(height: 4),
              _buildLabel(item, isSelected),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(BottomNavItem item, bool isSelected, bool isAnimating) {
    Widget iconWidget = AnimatedContainer(
      duration: animationDuration,
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? selectedColor : Colors.transparent,
      ),
      child: Icon(
        item.icon,
        color: isSelected ? Colors.white : unselectedColor,
        size: 24,
      ),
    );

    if (!isAnimating || !isSelected) return iconWidget;

    switch (animationType) {
      case AnimationType.scale:
        return TweenAnimationBuilder<double>(
          duration: animationDuration,
          tween: Tween(begin: 1.0, end: 1.2),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: iconWidget,
            );
          },
        );
      case AnimationType.rotation:
        return TweenAnimationBuilder<double>(
          duration: animationDuration,
          tween: Tween(begin: 0.0, end: 2 * math.pi),
          builder: (context, rotation, child) {
            return Transform.rotate(
              angle: rotation,
              child: iconWidget,
            );
          },
        );
      case AnimationType.bounce:
        return TweenAnimationBuilder<double>(
          duration: animationDuration,
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, -20 * value + 20),
              child: iconWidget,
            );
          },
        );
      case AnimationType.pulse:
        return TweenAnimationBuilder<double>(
          duration: animationDuration,
          tween: Tween(begin: 1.0, end: 1.3),
          builder: (context, scale, child) {
            return Container(
              width: 50 * scale,
              height: 50 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? selectedColor.withOpacity(0.8) : Colors.transparent,
              ),
              child: Icon(
                item.icon,
                color: isSelected ? Colors.white : unselectedColor,
                size: 24,
              ),
            );
          },
        );
      case AnimationType.slide:
        return TweenAnimationBuilder<Offset>(
          duration: animationDuration,
          tween: Tween(begin: const Offset(0, 0), end: const Offset(0, -0.2)),
          builder: (context, offset, child) {
            return Transform.translate(
              offset: offset,
              child: iconWidget,
            );
          },
        );
    }
  }

  Widget _buildLabel(BottomNavItem item, bool isSelected) {
    return AnimatedDefaultTextStyle(
      duration: animationDuration,
      style: TextStyle(
        color: isSelected ? selectedColor : unselectedColor,
        fontSize: isSelected ? 12 : 10,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      child: Text(item.label!),
    );
  }

  void _handleTap(BuildContext context, int index) {
    if (enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    
    context.read<NavigationBloc>().add(NavigateToPage(index));
  }
}
