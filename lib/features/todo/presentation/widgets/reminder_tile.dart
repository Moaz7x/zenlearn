import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:zenlearn/features/todo/domain/entities/reminder_entity.dart';
import 'package:zenlearn/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:zenlearn/features/todo/presentation/bloc/todo_event.dart';

import 'add_edit_reminder_dialog.dart';

class ReminderTile extends StatelessWidget {
  final ReminderEntity reminder;
  const ReminderTile({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.notifications),
      title: Text(reminder.message),
      subtitle: Text(DateFormat('MMM dd, yyyy - hh:mm a').format(reminder.reminderTime)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditReminderDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDeleteReminder(context),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteReminder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (context.mounted) {
                context.read<TodoBloc>().add(
                      DeleteReminderRequested(reminder.id!, reminder.todoId),
                    );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditReminderDialog(BuildContext context) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (_) => BlocProvider.value(
          value: context.read<TodoBloc>(),
          child: AddEditReminderDialog(
            todoId: reminder.todoId,
            existingReminder: reminder,
          ),
        ),
      );
    }
  }
}
