// lib/features/todo/presentation/widgets/add_reminder_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:zenlearn/features/todo/domain/entities/reminder_entity.dart';
import 'package:zenlearn/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:zenlearn/features/todo/presentation/bloc/todo_event.dart';

import '../bloc/todo_state.dart';

class AddReminderDialog extends StatefulWidget {
  final int todoId;
  final ReminderEntity? reminder;
  const AddReminderDialog({
    super.key,
    required this.todoId,
    this.reminder,
  });

  @override
  State<AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<AddReminderDialog> {
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
        child: Form(
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
                    return ListTile(
                      title: const Text('Reminder Time'),
                      subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDateTime,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                          );
                          if (time != null) {
                            context.read<TodoBloc>().add(UpdateReminderDateTime(DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                )));
                          }
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final reminder = ReminderEntity(
                        id: widget.reminder?.id,
                        reminderTime: _selectedDateTime,
                        message: _messageController.text,
                        todoId: widget.todoId,
                        isTriggered: false,
                      );

                      if (widget.reminder == null) {
                        context.read<TodoBloc>().add(AddReminderRequested(reminder));
                      } else {
                        context.read<TodoBloc>().add(UpdateReminderRequested(reminder));
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(widget.reminder == null ? 'Add Reminder' : 'Update Reminder'),
                ),
              ],
            ),
          ),
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
    _messageController = TextEditingController(
      text: widget.reminder?.message ?? '',
    );
    if (widget.reminder != null) {
      _selectedDateTime = widget.reminder!.reminderTime;
    } else {
      _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
    }
  }
}
