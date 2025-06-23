import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:zenlearn/features/todo/domain/entities/reminder_entity.dart';
import 'package:zenlearn/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:zenlearn/features/todo/presentation/bloc/todo_event.dart';

import '../bloc/todo_state.dart';

class AddEditReminderDialog extends StatefulWidget {
  final int todoId;
  final ReminderEntity? existingReminder;
  const AddEditReminderDialog({
    super.key,
    required this.todoId,
    this.existingReminder,
  });

  @override
  State<AddEditReminderDialog> createState() => _AddEditReminderDialogState();
}

class _AddEditReminderDialogState extends State<AddEditReminderDialog> {
  late TextEditingController _messageController;
  DateTime _selectedDateTime = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<TodoBloc, TodoState>(
        listenWhen: (previous, current) => current is ReminderDateTimeUpdated,
        listener: (context, state) {
          if (state is ReminderDateTimeUpdated) {
            _selectedDateTime = state.newDateTime;
          }
        },
        child: AlertDialog(
          title: Text(widget.existingReminder == null ? 'Add Reminder' : 'Edit Reminder'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Reminder Message',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a reminder message';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<TodoBloc, TodoState>(
                    buildWhen: (previous, current) => current is ReminderDateTimeUpdated,
                    builder: (context, state) {
                      return TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime),
                        ),
                        onTap: () => _selectDateTime(),
                        decoration: const InputDecoration(
                          labelText: 'Date and Time',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _saveReminder,
              child: const Text('Save'),
            ),
          ],
        ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(text: widget.existingReminder?.message ?? '');
    if (widget.existingReminder != null) {
      _selectedDateTime = widget.existingReminder!.reminderTime;
    } else {
      _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
    }
  }

  void _saveReminder() {
    if (!mounted) return;
    if (_formKey.currentState!.validate()) {
      final reminder = ReminderEntity(
        id: widget.existingReminder?.id,
        message: _messageController.text,
        reminderTime: _selectedDateTime,
        todoId: widget.todoId,
        isTriggered: false,
      );

      if (widget.existingReminder == null) {
        context.read<TodoBloc>().add(AddReminderRequested(reminder));
      } else {
        context.read<TodoBloc>().add(UpdateReminderRequested(reminder));
      }

      Navigator.pop(context);
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (!mounted || date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (!mounted || time == null) return;

    final selectedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    context.read<TodoBloc>().add(UpdateReminderDateTime(selectedDateTime));
  }
}
