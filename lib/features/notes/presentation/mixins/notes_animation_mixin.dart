import 'package:flutter/material.dart';

/// Mixin for handling animations in notes pages
mixin NotesAnimationMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  // Animation controllers
  late AnimationController _fabAnimationController;
  late AnimationController _filterAnimationController;
  
  // Animations
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _filterSlideAnimation;

  // Getters for animations
  Animation<double> get fabScaleAnimation => _fabScaleAnimation;
  Animation<double> get filterSlideAnimation => _filterSlideAnimation;

  /// Animates the FAB entrance
  void animateFabEntrance() {
    if (mounted) {
      _fabAnimationController.forward();
    }
  }

  /// Animates the FAB exit
  void animateFabExit() {
    if (mounted) {
      _fabAnimationController.reverse();
    }
  }

  /// Animates the filter bar entrance
  void animateFilterEntrance() {
    if (mounted) {
      _filterAnimationController.forward();
    }
  }

  /// Animates the filter bar exit
  void animateFilterExit() {
    if (mounted) {
      _filterAnimationController.reverse();
    }
  }

  /// Cleanup method to be called in dispose
  void disposeAnimationMixin() {
    _fabAnimationController.dispose();
    _filterAnimationController.dispose();
  }

  /// Initializes all animations for the notes page
  void initializeAnimations() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));

    _filterSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    ));

    // Animate FAB entrance
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fabAnimationController.forward();
      }
    });

    // Start filter animation
    _filterAnimationController.forward();
  }

  /// Resets all animations to their initial state
  void resetAnimations() {
    if (mounted) {
      _fabAnimationController.reset();
      _filterAnimationController.reset();
    }
  }
}
