import 'package:flutter/material.dart';

class ColorPickerWidget extends StatelessWidget {
  final int? selectedColor;
  final ValueChanged<int?> onColorSelected;

  const ColorPickerWidget({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      Colors.transparent, // Option for no color
      Colors.red.shade100,
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.yellow.shade100,
      Colors.purple.shade100,
      Colors.orange.shade100,
      Colors.teal.shade100,
    ];

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: colors.map((color) {
        final int colorValue = color.value;
        final bool isSelected = selectedColor == colorValue;
        return GestureDetector(
          onTap: () {
            // If transparent is selected and it's already the selected color, deselect it (set to null)
            if (color == Colors.transparent && isSelected) {
              onColorSelected(null);
            } else {
              onColorSelected(colorValue);
            }
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
            child: color == Colors.transparent
                ? Center(
                    child: Icon(
                      Icons.close,
                      color: isSelected ? Colors.black : Colors.grey,
                      size: 20,
                    ),
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
