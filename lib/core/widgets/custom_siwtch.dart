import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onToggle;
  final String activeIcon;
  final String inactiveIcon;
  final double width;
  final double height;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? toggleColor;
  final Duration animationDuration;

  const CustomSwitch({
    super.key,
    required this.value,
    required this.onToggle,
    this.activeIcon = 'assets/images/add.png',
    this.inactiveIcon = 'assets/images/remove-folder.png',
    this.width = 100.0,
    this.height = 55.0,
    this.activeColor,
    this.inactiveColor,
    this.toggleColor,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> with SingleTickerProviderStateMixin {
  late bool _isOn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = widget.activeColor ?? theme.colorScheme.primary;
    final inactiveColor = widget.inactiveColor ?? theme.colorScheme.surface;
    final toggleColor = widget.toggleColor ?? theme.colorScheme.secondary;
    final toggleSize = widget.height - 10;

    return GestureDetector(
      onTap: _toggleSwitch,
      child: AnimatedContainer(
        duration: widget.animationDuration,
        width: widget.width,
        height: widget.height,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: _isOn ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: _isOn ? Alignment.centerRight : Alignment.centerLeft,
              child: AnimatedContainer(
                duration: widget.animationDuration,
                width: toggleSize,
                height: toggleSize,
                decoration: BoxDecoration(
                  color: toggleColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    _isOn ? widget.activeIcon : widget.inactiveIcon,
                    color: _isOn ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                    width: toggleSize * 0.6,
                    height: toggleSize * 0.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant CustomSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _isOn = widget.value;
    }
  }

  @override
  void initState() {
    super.initState();
    _isOn = widget.value;
  }

  void _toggleSwitch() {
    setState(() {
      _isOn = !_isOn;
    });
    widget.onToggle(_isOn);
  }
}
