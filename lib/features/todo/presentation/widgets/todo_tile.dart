// lib/features/todo/presentation/widgets/todo_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zenlearn/core/widgets/custom_checkbox.dart';
import 'package:zenlearn/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:zenlearn/features/todo/presentation/bloc/todo_state.dart';

import '../../domain/entities/todo_entity.dart';

class TodoTile extends StatelessWidget {
  final TodoEntity todo;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onView;
  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    Color? getColor(int priority) {
      if (priority == 1) {
        return Colors.blue.shade200;
      } else if (priority == 2) {
        return Colors.amber.shade600;
      } else {
        return Colors.pink;
      }
    }

    final theme = Theme.of(context).colorScheme;
    return Container(
      decoration:
          BoxDecoration(color: getColor(todo.priority), borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: BlocSelector<TodoBloc, TodoState, bool>(
          selector: (state) {
            return todo.isCompleted;
          },
          builder: (context, state) {
            return CustomCheckbox(
              value: todo.isCompleted,
              onChanged: (_) => onToggle(),
            );
          },
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.dueDate != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Due: ${_formatDate(todo.dueDate!)}',
                    style: TextStyle(color: theme.tertiary, fontSize: 12),
                  ),
                  Row(
                    children: [
                      Text(
                        "${todo.dueDate!.hour} : ${todo.dueDate!.minute} ",
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Icon(Icons.timer)
                    ],
                  )
                ],
              ),
            Text(
              todo.title,
              style: TextStyle(
                decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                color: theme.primary,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description.isNotEmpty == true)
              Text(
                todo.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: theme.inversePrimary),
              ),
            if (todo.subtodos.isNotEmpty)
              Text(
                '${todo.subtodos.where((s) => s.isCompleted).length}/${todo.subtodos.length} subtasks completed',
                style: TextStyle(color: theme.secondary, fontSize: 12),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [Icon(Icons.visibility), SizedBox(width: 8), Text('View')],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete')
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'view':
                onView();
                break;
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
        ),
        onTap: onView,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
