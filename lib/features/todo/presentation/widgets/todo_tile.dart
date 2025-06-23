// lib/features/todo/presentation/widgets/todo_tile.dart
import 'package:flutter/material.dart';
import 'package:zenlearn/core/widgets/custom_checkbox.dart';

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
    final theme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CustomCheckbox(
          value: todo.isCompleted,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: theme.primary,
          ),
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
              Text(
                todo.priority == 1? 'Low' : todo.priority ==2 ? 'Mid' : 'High',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: todo.priority == 1? Colors.blueAccent : todo.priority ==2 ? Colors.orange : Colors.pink),
              ),
            if (todo.dueDate != null)
              Text(
                'Due: ${_formatDate(todo.dueDate!)}',
                style: TextStyle(color: theme.tertiary, fontSize: 12),
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
