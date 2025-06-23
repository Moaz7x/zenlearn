import 'package:flutter/material.dart';

/// A fully custom dropdown widget built from scratch.
///
/// This widget renders its menu using an [OverlayEntry] and uses a
/// [SizeTransition] to animate the dropdown list.
class CustomDropdown<T> extends StatefulWidget {
  /// The list of items to display in the dropdown.
  final List<T> items;

  /// The currently selected value.
  final T? value;

  /// Callback called when the user selects a new item.
  final ValueChanged<T>? onChanged;

  /// Text to show when no value is selected.
  final String hint;

  /// Optional custom builder for each dropdown item.
  final Widget Function(T item)? itemBuilder;

  const CustomDropdown({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.hint = 'Select an option',
    this.itemBuilder,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;

  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final theme = Theme.of(context); // Use standard theme access

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.03,
            vertical: screenSize.height * 0.02,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface, // Use theme color
            border: Border.all(color: theme.colorScheme.secondary), // Use theme color
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.value != null ? widget.value.toString() : widget.hint,
                  style: TextStyle(
                    color: widget.value != null
                        ? theme.colorScheme.primary // Use theme color
                        : Colors.grey.shade600,
                    fontSize: screenSize.width * 0.04,
                  ),
                ),
              ),
              Icon(
                _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: theme.colorScheme.primary, // Use theme color
                size: screenSize.width * 0.06,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Animation controller for the dropdown open/close effect.
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sizeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  /// Creates an [OverlayEntry] that contains the dropdown list.
  OverlayEntry _createOverlayEntry() {
    // Find the position & size of the current widget.
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size screenSize = MediaQuery.of(context).size;
    final theme = Theme.of(context); // Use standard theme access

    return OverlayEntry(
      builder: (BuildContext context) => GestureDetector(
        // Tapping anywhere outside the dropdown will close it.
        onTap: _removeOverlay,
        behavior: HitTestBehavior.translucent,
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: <Widget>[
              Positioned(
                width: size.width,
                left: offset.dx,
                top: offset.dy + size.height,
                child: CompositedTransformFollower(
                  link: _layerLink,
                  offset: const Offset(0.0, 0),
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: SizeTransition(
                      sizeFactor: _sizeAnimation,
                      axisAlignment: -1.0,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: screenSize.height * 0.5,
                        ),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          children: widget.items.map((T item) {
                            final bool isSelected = widget.value == item;
                            return ListTile(
                              // Add a vertical colored line if this item is selected.
                              leading: Container(
                                width: 4,
                                height: screenSize.height * 0.05,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.colorScheme.primary // Use theme color
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              title: widget.itemBuilder != null
                                  ? widget.itemBuilder!(item)
                                  : Text(
                                      item.toString(),
                                      style: TextStyle(
                                        color: isSelected
                                            ? theme.colorScheme.primary // Use theme color
                                            : theme.colorScheme.secondary, // Use theme color
                                        fontSize: screenSize.width * 0.04,
                                      ),
                                    ),
                              onTap: () {
                                if (widget.onChanged != null) {
                                  widget.onChanged!(item);
                                }
                                _removeOverlay();
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Removes the dropdown overlay.
  void _removeOverlay() {
    if (_isDropdownOpen) {
      _animationController.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
        _isDropdownOpen = false;
      });
    }
  }

  /// Inserts the [OverlayEntry] into the [Overlay] to display the dropdown.
  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _isDropdownOpen = true;
    _animationController.forward();
  }

  /// Toggles the dropdown menu open or closed.
  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }
}
