import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zenlearn/core/utils/snackbar_utils.dart';

import '../../../../core/widgets/custom_date_time_picker.dart';
import '../../../../core/widgets/custom_dialog.dart';
import '../../domain/entities/todo_entity.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';

String formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

String formatPriority(int priority) {
  switch (priority) {
    case 1:
      return 'Low';
    case 2:
      return 'Mid';
    case 3:
      return 'High';
    default:
      return 'Low';
  }
}

void saveTodo({
  required TextEditingController titleController,
  required TextEditingController descriptionController,
  required BuildContext context,
  required bool isCompleted,
  required bool isEditing,
  required TodoEntity? todo,
  required int? priority,
  required DateTime? selectedDate,
}) {
  if (titleController.text.trim().isEmpty) {
    context.showGlassSnackBar(
      message: 'Please Enter A Title *',
    );
    return;
  }

  final todoToSave = TodoEntity(
    id: isEditing ? todo!.id : null,
    title: titleController.text.trim(),
    description: descriptionController.text.trim(),
    isCompleted: isCompleted,
    priority: priority ?? 1,
    createdAt: isEditing ? todo!.createdAt : DateTime.now(),
    dueDate: selectedDate,
    subtodos: isEditing ? todo!.subtodos : [],
    reminders: isEditing ? todo!.reminders : [],
  );

  if (isEditing) {
    context.read<TodoBloc>().add(UpdateTodoRequested(todoToSave));
  } else {
    context.read<TodoBloc>().add(AddTodoRequested(todoToSave));
  }
}

void selectDate(
    {required BuildContext context, required void Function(DateTime, bool) onConfirm}) async {
  showDialog(
    context: context,
    builder: (_) => ResponsiveDateTimePicker(
      onConfirm: onConfirm,
      // initialDate: DateTime.now(),
      //   // For adding a new todo, the dueDate is set in saveTodo
      // },
    ),
  );
}

void selectPriority({
  required BuildContext context,
  required void Function(int?)? onSelected,
  required void Function() onPressed,
}) async {
  showDialog(
    context: context,
    builder: (context) => GlassDialog(
        content: Column(
      children: [
        DropdownMenu(
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: 1, label: 'Low'),
            DropdownMenuEntry(value: 2, label: 'Mid'),
            DropdownMenuEntry(value: 3, label: 'High'),
          ],
          hintText: 'Priority',
          width: 200,
          onSelected: onSelected,
        ),
        Wrap(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // onPressed();
                Navigator.pop(context);
              },
              label: const Text('Save'),
              icon: const Icon(Icons.save),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              label: const Text('Cancel'),
              icon: const Icon(Icons.cancel_outlined),
            ),
          ],
        )
      ],
    )),
  );
}

void showDeleteDialog({required BuildContext context, TodoEntity? todo}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Delete Todo'),
      content: Text(
          'Are you sure you want to delete "${todo!.title}"? This will also delete all subtasks and cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            context.read<TodoBloc>().add(DeleteTodoRequested(todo.id!));
            Navigator.pop(context); // Close dialog
            Navigator.pop(context); // Go back to previous page
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
