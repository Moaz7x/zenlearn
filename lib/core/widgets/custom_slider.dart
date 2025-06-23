import 'package:flutter/material.dart';

class CustomSlider extends StatefulWidget {
  final double value; // Added value property
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final String? label;
  final bool showValueIndicator;

  const CustomSlider({
    super.key,
    required this.value, // Made value required
    this.min = 0.0,
    this.max = 1.0,
    this.onChanged,
    this.onChangeEnd,
    this.onChangeStart,
    this.label,
    this.showValueIndicator = true,
  });

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

// Removed Bloc imports

// Define simple constants locally for this widget
// const Color _kErrorColor = Colors.orange;
// const Color _kPrimaryColor = Colors.blue;
// const Color _kSecondaryColor = Colors.red;
// const Color _kTertiaryColor = Colors.green;

class _AppBorderRadius {
  static const BorderRadius medium = BorderRadius.all(Radius.circular(12));
  static const BorderRadius full = BorderRadius.all(Radius.circular(999));
  static const BorderRadius small = BorderRadius.all(Radius.circular(4));
}

class _AppDurations {
  static const Duration medium = Duration(milliseconds: 300);
}

class _AppPaddings {
  static const EdgeInsets button = EdgeInsets.all(16.0);
  static const EdgeInsets slider = EdgeInsets.all(2.0);
  static const EdgeInsets small = EdgeInsets.all(8.0);
}

class _AppShadows {
  static const BoxShadow medium = BoxShadow(
    color: Colors.black26,
    offset: Offset(0, 4),
    blurRadius: 8,
  );
}

class _CustomSliderState extends State<CustomSlider> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  // Removed Bloc dependencies and state variables

  @override
  Widget build(BuildContext context) {
    // Simplified build method, no longer depends on BlocBuilder
    return GestureDetector(
      onTapDown: (_) => _startInteraction(),
      onTapUp: (_) => _endInteraction(),

      onTapCancel: () => _endInteraction(), // Handle tap cancel
      onHorizontalDragUpdate: (details) {
        // Calculate new value based on drag position
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final localPosition = renderBox.globalToLocal(details.globalPosition);
        final double trackWidth =
            renderBox.size.width - (_AppPaddings.slider.horizontal); // Adjust for padding

        double adjustedLocalPositionDx = localPosition.dx;
        if (Directionality.of(context) == TextDirection.rtl) {
          adjustedLocalPositionDx = trackWidth - localPosition.dx;
        }

        final double newValue = widget.min +
            (widget.max - widget.min) * (adjustedLocalPositionDx / trackWidth).clamp(0.0, 1.0);
        widget.onChanged?.call(newValue);
      },
      onHorizontalDragStart: (_) => widget.onChangeStart ?? _startInteraction(),
      onHorizontalDragEnd: (_) => widget.onChangeEnd ?? _endInteraction(),
      child: _buildSliderBody(context), // Pass context directly
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: _AppDurations.medium,
    );
    // Removed Bloc initialization event
  }

  Widget _buildLabel(BuildContext context) {
    return Padding(
      padding: _AppPaddings.button,
      child: Text(
        widget.label!,
        style: TextStyle(
          // Use theme color
          color: Theme.of(context).colorScheme.tertiary,
          fontSize: 16,
        ),
      ),
    );
  }

  // Simplified _buildSliderBody
  Widget _buildSliderBody(BuildContext context) {
    final theme = Theme.of(context);
    final double trackWidth = MediaQuery.of(context).size.width -
        (_AppPaddings.slider.horizontal); // Calculate track width

    return Container(
      padding: _AppPaddings.slider,
      decoration: BoxDecoration(
        borderRadius: _AppBorderRadius.medium,
        color: theme.colorScheme.primary.withOpacity(0.1), // Use theme color
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) _buildLabel(context),
          Stack(
            alignment: Alignment.centerLeft, // Align stack children to the left
            children: [
              _buildTrack(context), // Pass context
              _buildThumb(context, trackWidth), // Pass context and trackWidth
              if (widget.showValueIndicator)
                _buildValueIndicator(context, trackWidth), // Pass context and trackWidth
            ],
          ),
        ],
      ),
    );
  }

  // Simplified _buildThumb
  Widget _buildThumb(BuildContext context, double trackWidth) {
    final theme = Theme.of(context);
    // Calculate thumb position based on current value
    double thumbPosition = (widget.value.clamp(widget.min, widget.max) - widget.min) /
        (widget.max - widget.min) *
        trackWidth;

    if (Directionality.of(context) == TextDirection.rtl) {
      thumbPosition = trackWidth - thumbPosition;
    }

    return Positioned(
      left: thumbPosition, // Use calculated position
      child: ScaleTransition(
        scale: _scaleController,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary, // Use theme color
            shape: BoxShape.circle,
            boxShadow: const [_AppShadows.medium],
          ),
        ),
      ),
    );
  }

  // Simplified _buildTrack
  Widget _buildTrack(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 6,
      decoration: const BoxDecoration(
        borderRadius: _AppBorderRadius.full,
        // color: theme.colorScheme.error.withOpacity(0.5), // Use theme color
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (widget.value.clamp(widget.min, widget.max) - widget.min) /
            (widget.max - widget.min), // Use widget.value
        child: Container(
          decoration: BoxDecoration(
            borderRadius: _AppBorderRadius.full,
            color: theme.colorScheme.primary, // Use theme color
          ),
        ),
      ),
    );
  }

  // Simplified _buildValueIndicator
  Widget _buildValueIndicator(BuildContext context, double trackWidth) {
    final theme = Theme.of(context);
    // Calculate indicator position based on current value
    double indicatorPosition = (widget.value.clamp(widget.min, widget.max) - widget.min) /
        (widget.max - widget.min) *
        trackWidth;

    if (Directionality.of(context) == TextDirection.rtl) {
      indicatorPosition = trackWidth - indicatorPosition;
    }

    return Positioned(
      left: indicatorPosition - 20, // Adjust position to center over thumb
      top: -28,
      child: AnimatedOpacity(
        // Opacity based on whether the thumb is scaled (interaction)
        opacity: _scaleController.value > 0 ? 1.0 : 0.0,
        duration: _AppDurations.medium,
        child: Container(
          padding: _AppPaddings.small,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary, // Use theme color
            borderRadius: _AppBorderRadius.small,
          ),
          child: Text(
            widget.value.toStringAsFixed(1), // Use widget.value
            style: TextStyle(fontSize: 14, color: theme.colorScheme.onPrimary), // Use theme color
          ),
        ),
      ),
    );
  }

  void _endInteraction() {
    _scaleController.reverse();
    // Removed Bloc event
  }

  void _startInteraction() {
    _scaleController.forward();
    // Removed Bloc event
  }
}
