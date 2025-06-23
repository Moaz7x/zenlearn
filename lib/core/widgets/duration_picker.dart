import 'package:flutter/material.dart';

/// Utility for picking durations.
/// Returns null if cancelled.
Future<Duration?> showDurationPicker({
  required BuildContext context,
  Duration initialDuration = const Duration(hours: 1),
}) async {
  // For simplicity, using a dialog with predefined options or simple hour/minute inputs.
  // A more complex visual picker could be built if needed.

  Duration? selectedDuration = initialDuration;

  return await showDialog<Duration>(
    context: context,
    builder: (BuildContext dialogContext) {
      int hours = initialDuration.inHours;
      int minutes = initialDuration.inMinutes.remainder(60);

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select Task Duration'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Hours
                    Column(
                      children: [
                        const Text('Hours'),
                        NumberPicker( // Simple custom number picker
                          minValue: 0,
                          maxValue: 23,
                          value: hours,
                          onChanged: (value) => setState(() => hours = value),
                        ),
                      ],
                    ),
                    // Minutes
                    Column(
                      children: [
                        const Text('Minutes'),
                        NumberPicker(
                          minValue: 0,
                          maxValue: 59,
                          step: 5, // Step by 5 minutes
                          value: minutes,
                          onChanged: (value) => setState(() => minutes = value),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Display selected duration
                Text('Selected: ${hours}h ${minutes}m'),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(dialogContext).pop(null);
                },
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  selectedDuration = Duration(hours: hours, minutes: minutes);
                  // Prevent zero duration if needed
                  if (selectedDuration == Duration.zero) {
                    selectedDuration = null; // Or set a minimum duration
                  }
                  Navigator.of(dialogContext).pop(selectedDuration);
                },
              ),
            ],
          );
        },
      );
    },
  );
}

// Simple Number Picker Widget (replace with a package like numberpicker if preferred)
class NumberPicker extends StatelessWidget {
  final int minValue;
  final int maxValue;
  final int value;
  final int step;
  final ValueChanged<int> onChanged;

  const NumberPicker({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.value,
    this.step = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: value > minValue
              ? () => onChanged(value - step >= minValue ? value - step : minValue)
              : null,
        ),
        Text(value.toString().padLeft(2, '0')),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: value < maxValue
              ? () => onChanged(value + step <= maxValue ? value + step : maxValue)
              : null,
        ),
      ],
    );
  }
}

