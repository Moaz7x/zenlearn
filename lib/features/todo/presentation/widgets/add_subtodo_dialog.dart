// lib/features/todo/presentation/widgets/add_subtodo_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zenlearn/core/widgets/custom_dialog.dart';
import 'package:zenlearn/core/widgets/custom_input.dart';

import '../../domain/entities/subtodo_entity.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';

class AddSubtodoDialog extends StatefulWidget {
  // If provided, we're editing

  final int todoId;
  final SubtodoEntity? subtodo;
  const AddSubtodoDialog({
    super.key,
    required this.todoId,
    this.subtodo,
  });

  @override
  State<AddSubtodoDialog> createState() => _AddSubtodoDialogState();
}

class _AddSubtodoDialogState extends State<AddSubtodoDialog> {
  late TextEditingController _titleController;
  bool _isCompleted = false;

  bool get isEditing => widget.subtodo != null;

  @override
  Widget build(BuildContext context) {
    return BlocListener<TodoBloc, TodoState>(
        listenWhen: (previous, current) => current is TodoLoaded,
        listener: (context, state) {
          if (state is TodoLoaded) {
            final updatedTodo = state.todos.firstWhere((todo) => todo.id == widget.todoId);
            final updatedSubtodo =
                updatedTodo.subtodos.firstWhere((subtodo) => subtodo.id == widget.subtodo!.id);
            setState(() {
              _isCompleted = updatedSubtodo.isCompleted;
            });
          }
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.003,
          child: GlassDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isEditing ? 'Edit Subtask' : 'Add New Subtask'),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: 250,
                  child: CustomInput(
                    controller: _titleController,
                    hintText: 'Title',
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Wrap(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: _saveSubtodo,
                      child: Text(isEditing ? 'Save Changes' : 'Add Subtask'),
                    ),
                  ],
                ),
                if (isEditing) ...[
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.subtodo?.title ?? '');
    _isCompleted = widget.subtodo?.isCompleted ?? false;
  }

  void _saveSubtodo() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    final subtodo = SubtodoEntity(
      id: widget.subtodo?.id,
      title: _titleController.text.trim(),
      isCompleted: _isCompleted,
      todoId: widget.todoId,
    );

    if (context.mounted) {
      if (isEditing) {
        context.read<TodoBloc>().add(UpdateSubTodoRequested(subtodo));
      } else {
        context.read<TodoBloc>().add(AddSubTodoRequested(subtodo));
      }
    }

    Navigator.pop(context);
  }
}
