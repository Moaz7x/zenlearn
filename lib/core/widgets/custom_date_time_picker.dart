import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResponsiveDateTimePicker extends StatefulWidget {
  final void Function(DateTime, bool) onConfirm;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const ResponsiveDateTimePicker({
    super.key,
    required this.onConfirm,
    this.initialDate,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<ResponsiveDateTimePicker> createState() => _ResponsiveDateTimePickerState();
}

class _ResponsiveDateTimePickerState extends State<ResponsiveDateTimePicker> {
  late DateTime _selectedDate;
  int _hour = 9;
  int _minute = 0;
  bool _isAM = true;
  bool _repeat = false;

  DateTime get finalDateTime {
    final hour24 = _isAM ? (_hour == 12 ? 0 : _hour) : (_hour == 12 ? 12 : _hour + 12);
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour24,
      _minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            constraints: BoxConstraints(
              maxWidth: isSmallScreen ? screenSize.width * 0.9 : 500,
              maxHeight: screenSize.height * 0.8,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context, isSmallScreen),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  _buildCalendar(isSmallScreen),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  _buildTimePicker(isSmallScreen),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  _buildActions(isSmallScreen),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    if (widget.initialDate != null) {
      _hour =
          widget.initialDate!.hour > 12 ? widget.initialDate!.hour - 12 : widget.initialDate!.hour;
      if (_hour == 0) _hour = 12;
      _minute = widget.initialDate!.minute;
      _isAM = widget.initialDate!.hour < 12;
    }
  }

  Widget _buildActions(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(top: isSmallScreen ? 8.0 : 12.0),
      child: isSmallScreen
          ? Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onConfirm(finalDateTime, _repeat);
                      Navigator.pop(context);
                    },
                    child: const Text("Confirm"),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onConfirm(finalDateTime, _repeat);
                      Navigator.pop(context);
                    },
                    child: const Text("Confirm"),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAmPmToggle(bool isSmallScreen) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Period',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: isSmallScreen ? 12 : 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        ToggleButtons(
          borderRadius: BorderRadius.circular(8),
          constraints: BoxConstraints(
            minWidth: isSmallScreen ? 35 : 45,
            minHeight: isSmallScreen ? 35 : 40,
          ),
          isSelected: [_isAM, !_isAM],
          onPressed: (i) => setState(() => _isAM = i == 0),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12),
              child: Text("AM", style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12),
              child: Text("PM", style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendar(bool isSmallScreen) {
    final daysInMonth = DateUtils.getDaysInMonth(_selectedDate.year, _selectedDate.month);
    final startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final offset = startDate.weekday % 7;
    final today = DateTime.now();

    final List<Widget> dayWidgets = List.generate(offset, (index) => const SizedBox());

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_selectedDate.year, _selectedDate.month, day);
      final isSelected = _selectedDate.day == day &&
          _selectedDate.month == date.month &&
          _selectedDate.year == date.year;
      final isToday = date.day == today.day && date.month == today.month && date.year == today.year;
      final isPastDate = widget.firstDate != null && date.isBefore(widget.firstDate!);
      final isFutureDate = widget.lastDate != null && date.isAfter(widget.lastDate!);
      final isDisabled = isPastDate || isFutureDate;

      dayWidgets.add(
        GestureDetector(
          onTap: isDisabled ? null : () => setState(() => _selectedDate = date),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Theme.of(context).colorScheme.primary : null,
              border: isToday && !isSelected
                  ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                  : null,
            ),
            alignment: Alignment.center,
            margin: EdgeInsets.all(isSmallScreen ? 2 : 4),
            child: Text(
              '$day',
              style: TextStyle(
                color: isDisabled
                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.3)
                    : isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(height: isSmallScreen ? 4 : 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 4 : 8,
            vertical: 4,
          ),
          childAspectRatio: 1.0,
          children: dayWidgets,
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 8,
      children: [
        Text(
          'Select Date & Time',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                iconSize: isSmallScreen ? 20 : 24,
                onPressed: () => setState(() {
                  _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
                }),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  DateFormat.yMMMM().format(_selectedDate),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                iconSize: isSmallScreen ? 20 : 24,
                onPressed: () => setState(() {
                  _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRepeatCheckbox(bool isSmallScreen) {
    return InkWell(
      onTap: () => setState(() => _repeat = !_repeat),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: _repeat,
              onChanged: (v) => setState(() => _repeat = v!),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Text(
              "Repeat",
              style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: isSmallScreen ? 8 : 16,
        runSpacing: isSmallScreen ? 8 : 12,
        children: [
          _numberInput('Hour', _hour, (v) => setState(() => _hour = v.clamp(1, 12)), isSmallScreen),
          _numberInput(
              'Min', _minute, (v) => setState(() => _minute = v.clamp(0, 59)), isSmallScreen),
          _buildAmPmToggle(isSmallScreen),
          _buildRepeatCheckbox(isSmallScreen),
        ],
      ),
    );
  }

  Widget _numberInput(String label, int value, void Function(int) onChanged, bool isSmallScreen) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: isSmallScreen ? 12 : 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => onChanged(value + 1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: SizedBox(
                  width: isSmallScreen ? 45 : 55,
                  height: isSmallScreen ? 30 : 35,
                  child: const Icon(Icons.keyboard_arrow_up, size: 20),
                ),
              ),
              Container(
                width: isSmallScreen ? 45 : 55,
                height: isSmallScreen ? 35 : 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                ),
                child: Text(
                  value.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              InkWell(
                onTap: () => onChanged(value - 1),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                child: SizedBox(
                  width: isSmallScreen ? 45 : 55,
                  height: isSmallScreen ? 30 : 35,
                  child: const Icon(Icons.keyboard_arrow_down, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
