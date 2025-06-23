import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zenlearn/core/utils/snackbar_utils.dart';
import 'package:zenlearn/features/todo/domain/entities/todo_entity.dart';
import 'package:zenlearn/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:zenlearn/features/todo/presentation/bloc/todo_state.dart';

import '../../../../core/widgets/custom_siwtch.dart';
import '../bloc/todo_event.dart';
import '../utils/edit_todo_page_utils.dart';

int? _priority;
int? get getPriority => _priority;

class EditTodoPageStatusCard extends StatefulWidget {
  final bool isCompleted;
  final bool isEditing;
  final TodoEntity? todo;
  final int? priority;
  final DateTime? selectedDate;
  final TextEditingController? titleController;
  final TextEditingController? descriptionController;
  const EditTodoPageStatusCard({
    super.key,
    this.isCompleted = false,
    this.todo,
    this.selectedDate,
    this.priority,
    this.titleController,
    this.descriptionController,
    required this.isEditing,
  });

  @override
  State<EditTodoPageStatusCard> createState() => _EditTodoPageStatusCardState();
}

DateTime? selectedDate;
DateTime? get getSelectedDate => selectedDate;

class _EditTodoPageStatusCardState extends State<EditTodoPageStatusCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status & Schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Completed: '),
                    Text(
                        widget.isCompleted ? 'This todo is completed' : 'This todo is in progress'),
                  ],
                ),
                BlocSelector<TodoBloc, TodoState, bool>(
                  selector: (state) {
                    return widget.todo?.isCompleted ?? false;
                  },
                  builder: (context, state) {
                    return CustomSwitch(
                      activeIcon: 'assets/images/pause.png',
                      inactiveIcon: 'assets/images/play.png',
                      value: widget.todo?.isCompleted ?? false,
                      height: 24,
                      width: 44,
                      onToggle: (value) {
                        if (widget.todo != null) {
                           context.read<TodoBloc>().add(UpdateTodoCompletionStatus(widget.todo!));
                          if (mounted) {
                            context.read<TodoBloc>().add(LoadTodos());
                          }
                          
                        } else {
                          context.showGlassSnackBar(
                              message: 'You Must Add Todo Before You Complete IT !');
                        }
                      },
                    );
                  },
                )
              ],
            ),
            const Divider(thickness: 3),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Due Date'),
              subtitle: Text(selectedDate == null ? 'No due date set' : formatDate(selectedDate!)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedDate != null) const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              onTap: () => selectDate(
                context: context,
                onConfirm: (date, p1) {
                  setState(() {
                    selectedDate = date;
                  });
                },
              ),
            ),
            const Divider(thickness: 3),
            ListTile(
              leading: const Icon(Icons.priority_high_rounded),
              title: const Text('Priority'),
              subtitle: Text(
                _priority == null ? 'No Priority Set' : formatPriority(_priority!),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.selectedDate != null) const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              onTap: () => selectPriority(
                context: context,
                onPressed: () {
                  // saveTodo(
                  //   titleController: widget.titleController!,
                  //   descriptionController: widget.descriptionController!,
                  //   context: context,
                  //   isCompleted: widget.isCompleted,
                  //   isEditing: widget.isEditing,
                  //  x todo: widget.todo,
                  //   priority: _priority,
                  //   selectedDate: selectedDate,
                  // );
                },
                onSelected: (value) {
                  setState(() {
                    _priority = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    selectedDate = widget.todo?.dueDate ?? DateTime.now();
    _priority = widget.todo?.priority ?? 1;
    super.initState();
  }
}
