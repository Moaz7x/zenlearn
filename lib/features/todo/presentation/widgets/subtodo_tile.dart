// lib/features/todo/presentation/widgets/subtodo_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zenlearn/core/widgets/custom_checkbox.dart';
import 'package:zenlearn/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:zenlearn/features/todo/presentation/bloc/todo_event.dart';

import '../../domain/entities/subtodo_entity.dart';
import '../bloc/todo_state.dart';

class SubtodoTile extends StatefulWidget {
  final SubtodoEntity subtodo;
  final Function(bool?)? onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const SubtodoTile({
    super.key,
    required this.subtodo,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<SubtodoTile> createState() => _SubtodoTileState();
}

class _SubtodoTileState extends State<SubtodoTile> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      buildWhen: (previous, current) => current is TodoLoaded,
      builder: (context, state) {
        SubtodoEntity currentSubtodo = widget.subtodo;
        if (state is TodoLoaded) {
          final updatedTodo = state.todos.firstWhere((todo) => todo.id == widget.subtodo.todoId);
          currentSubtodo =
              updatedTodo.subtodos.firstWhere((subtodo) => subtodo.id == widget.subtodo.id);
        }
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: BlocSelector<TodoBloc, TodoState, bool>(
              selector: (state) {
                if (state is TodoLoaded) {
                  final todo = state.todos.firstWhere((todo) => todo.id == widget.subtodo.todoId);
                  final subtodo = todo.subtodos.firstWhere((sub) => sub.id == widget.subtodo.id);
                  return subtodo.isCompleted;
                }
                return widget.subtodo.isCompleted;
              },
              builder: (context, isCompleted) {
                return CustomCheckbox(
                  value: isCompleted,
                  onChanged: (x) {
                    SubtodoEntity updated = SubtodoEntity(
                      id: widget.subtodo.id,
                      title: widget.subtodo.title,
                      isCompleted: x,
                      todoId: widget.subtodo.todoId,
                    );
                    if (context.mounted) {
                      context.read<TodoBloc>().add(UpdateSubTodoRequested(updated));
                    }
                  },
                );
              },
            ),
            title: Text(
              currentSubtodo.title,
              style: TextStyle(
                decoration: currentSubtodo.isCompleted ? TextDecoration.lineThrough : null,
                color: currentSubtodo.isCompleted ? Colors.grey : null,
              ),
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
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
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    widget.onEdit();
                    break;
                  case 'delete':
                    widget.onDelete();
                    break;
                }
              },
            ),
          ),
        );
      },
    );
  }
}
