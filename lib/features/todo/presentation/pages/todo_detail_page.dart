// lib/features/todo/presentation/pages/todo_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zenlearn/core/utils/snackbar_utils.dart';
import 'package:zenlearn/core/widgets/custom_checkbox.dart';
import 'package:zenlearn/core/widgets/custom_dialog.dart';
import 'package:zenlearn/core/widgets/custom_linear_progress_indecator.dart';

import '../../domain/entities/subtodo_entity.dart';
import '../../domain/entities/todo_entity.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../widgets/add_reminder_dialog.dart';
import '../widgets/add_subtodo_dialog.dart';
import '../widgets/reminder_tile.dart';
import '../widgets/subtodo_tile.dart';
import 'edit_todo_page.dart';

class TodoDetailPage extends StatefulWidget {
  final TodoEntity todo;
  const TodoDetailPage({super.key, required this.todo});

  @override
  State<TodoDetailPage> createState() => _TodoDetailPageState();
}


class _TodoDetailPageState extends State<TodoDetailPage> {
  late TodoEntity currentTodo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Details'),
        leading: IconButton(
            onPressed: () {
              if (mounted) {
                context.read<TodoBloc>().add(LoadTodos());
                Future.delayed(const Duration(milliseconds: 100), () {
                  context.pop();
                });
              } else {
                context.pop();
              }
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<TodoBloc>(),
                    child: EditTodoPage(todo: currentTodo),
                  ),
                ),
              );
              // Refresh the current todo data if edited
              if (result == true) {
                context.read<TodoBloc>().add(LoadTodos());
              }
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle',
                child: Row(
                  children: [
                    Icon(currentTodo.isCompleted ? Icons.undo : Icons.check),
                    const SizedBox(width: 8),
                    Text(currentTodo.isCompleted ? 'Mark Incomplete' : 'Mark Complete'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Todo'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'toggle':
                  context.read<TodoBloc>().add(ToggleTodoCompletion(currentTodo.id!));
                  break;
                case 'delete':
                  _showDeleteDialog();
                  break;
              }
            },
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<TodoBloc, TodoState>(
            listenWhen: (previous, current) =>
                current is TodoError || current is TodoOperationSuccess,
            listener: (context, state) {
              if (state is TodoError) {
                context.showGlassSnackBar(
                  message: state.message,
                );
              } else if (state is TodoOperationSuccess) {
                context.showGlassSnackBar(
                  message: state.message,
                );
                // If todo was deleted, go back
                if (state.message.contains('deleted')) {
                  Navigator.pop(context, true);
                }
              }
            },
          ),
          BlocListener<TodoBloc, TodoState>(
            listenWhen: (previous, current) => current is TodoLoaded,
            listener: (context, state) {
              if (state is TodoLoaded) {
                // Update current todo with fresh data
                final updatedTodo = state.todos.firstWhere(
                  (todo) => todo.id == currentTodo.id,
                  orElse: () => currentTodo,
                );
                currentTodo = updatedTodo;
                // Reload subtodos when todo is updated
                context.read<TodoBloc>().add(LoadReminders(currentTodo.id!));
                context.read<TodoBloc>().add(LoadSubTodos(currentTodo.id!));
              }
            },
          ),
        ],
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<TodoBloc>().add(LoadSubTodos(currentTodo.id!));
            context.read<TodoBloc>().add(LoadReminders(currentTodo.id!));
            context.read<TodoBloc>().add(LoadTodos());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTodoHeader(),
                const SizedBox(height: 24),
                _buildRemindersSection(),
                const SizedBox(height: 24),
                _buildSubtodosSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    currentTodo = widget.todo;
    // Load subtodos and reminders when page opens
    context.read<TodoBloc>().add(LoadSubTodos(widget.todo.id!));
    context.read<TodoBloc>().add(LoadReminders(widget.todo.id!));
  }

  Widget _buildRemindersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reminders',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => _showAddReminderDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Reminder'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<TodoBloc, TodoState>(
          buildWhen: (previous, current) =>
              current is RemindersLoading || current is RemindersLoaded || current is TodoError,
          builder: (context, state) {
            if (state is RemindersLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is RemindersLoaded) {
              if (state.reminders.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No reminders set'),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.reminders.length,
                itemBuilder: (context, index) => ReminderTile(
                  reminder: state.reminders[index],
                ),
              );
            }
            return Container();
          },
        ),
      ],
    );
  }

  Widget _buildSubtodosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Subtasks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddSubtodoDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Subtask'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<TodoBloc, TodoState>(
          buildWhen: (previous, current) =>
              current is SubTodoLoading || current is SubTodoLoaded || current is TodoError,
          builder: (context, state) {
            if (state is SubTodoLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SubTodoLoaded) {
              if (state.todos.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Icon(Icons.assignment, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No subtasks yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Break down this todo into smaller tasks',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final completedCount = state.todos.where((s) => s.isCompleted).length;
              final totalCount = state.todos.length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Progress'),
                              Text('$completedCount / $totalCount'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          CustomLinearProgressIndicator(
                            value: totalCount > 0 ? completedCount / totalCount : 0,
                            backgroundColor: Theme.of(context).colorScheme.onSurface,
                            progressColor: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.todos.length,
                    itemBuilder: (context, index) {
                      final subtodo = state.todos[index];
                      return BlocSelector<TodoBloc, TodoState, SubtodoEntity>(
                        selector: (state) {
                          if (state is SubTodoLoaded) {
                            return state.todos.firstWhere(
                              (t) => t.id == subtodo.id,
                              orElse: () => subtodo,
                            );
                          }
                          return subtodo;
                        },
                        builder: (context, currentSubtodo) {
                          return SubtodoTile(
                            subtodo: currentSubtodo,
                            onToggle: (s) {
                              final SubtodoEntity updatedsub = SubtodoEntity(
                                title: currentSubtodo.title,
                                isCompleted: s ?? false,
                                todoId: currentSubtodo.todoId,
                              );
                              context.read<TodoBloc>().add(
                                    UpdateSubTodoRequested(updatedsub),
                                  );
                              context.read<TodoBloc>().add(UpdateTodoRequested(widget.todo));
                              context.read<TodoBloc>().add(LoadSubTodos(currentSubtodo.todoId));
                              if (mounted) {
                                 context.read<TodoBloc>().add(LoadTodos());
                               }
                            },
                            onEdit: () => _showEditSubtodoDialog(currentSubtodo),
                            onDelete: () => _showDeleteSubtodoDialog(currentSubtodo),
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            }
            return Container();
          },
        ),
      ],
    );
  }

  Widget _buildTodoHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BlocSelector<TodoBloc, TodoState, bool>(
                  selector: (state) {
                    if (state is TodoLoaded) {
                      final todo = state.todos.firstWhere(
                        (t) => t.id == currentTodo.id,
                        orElse: () => currentTodo,
                      );
                      return todo.isCompleted;
                    }
                    return currentTodo.isCompleted;
                  },
                  builder: (context, isCompleted) {
                    return CustomCheckbox(
                      value: isCompleted,
                      onChanged: (_) {
                        context.read<TodoBloc>().add(
                              ToggleTodoCompletion(currentTodo.id!),
                            );
                        if (mounted) {
                          context.read<TodoBloc>().add(LoadTodos());
                        }
                      },
                    );
                  },
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: BlocSelector<TodoBloc, TodoState, bool>(
                    selector: (state) {
                      return currentTodo.isCompleted;
                    },
                    builder: (context, state) {
                      return Text(
                        currentTodo.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          decoration: currentTodo.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            if (currentTodo.description.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currentTodo.description,
                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.inversePrimary),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Created: ${_formatDate(currentTodo.createdAt)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            if (currentTodo.dueDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Due: ${_formatDate(currentTodo.dueDate!)}',
                    style: TextStyle(color: Colors.orange[700]),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            BlocSelector<TodoBloc, TodoState, bool>(
              selector: (state) {
                if (state is TodoLoaded) {
                  final todo = state.todos.firstWhere(
                    (t) => t.id == currentTodo.id,
                    orElse: () => currentTodo,
                  );
                  return todo.isCompleted;
                }
                return currentTodo.isCompleted;
              },
              builder: (context, isCompleted) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : Colors.blue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isCompleted ? 'Completed' : 'In Progress',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddReminderDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Reminder'),
        content: AddReminderDialog(todoId: currentTodo.id!),
      ),
    );
  }

  void _showAddSubtodoDialog() {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<TodoBloc>(),
        child: AddSubtodoDialog(todoId: currentTodo.id!),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (_) => GlassDialog(
          type: GlassDialogType.error,
          content: Column(
            children: [
              const Text('Delete Todo'),
              const SizedBox(
                height: 40,
              ),
              Text(
                  'Are you sure you want to delete "${currentTodo.title}"? This will also delete all subtasks.'),
              const SizedBox(
                height: 20,
              ),
              Wrap(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<TodoBloc>().add(DeleteTodoRequested(currentTodo.id!));
                      Navigator.pop(context);
                    },
                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              )
            ],
          )),
    );
  }

  void _showDeleteSubtodoDialog(SubtodoEntity subtodo) {
    showDialog(
      context: context,
      builder: (_) => GlassDialog(
          content: Column(
        children: [
          const Text('Delete Subtask'),
          const SizedBox(
            height: 40,
          ),
          Text('Are you sure you want to delete "${subtodo.title}"?'),
          const SizedBox(
            height: 20,
          ),
          Wrap(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.read<TodoBloc>().add(
                        DeleteSubTodoRequested(subtodo.id!, currentTodo.id!),
                      );
                  Navigator.pop(context);
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          )
        ],
      )),
    );
  }

  void _showEditSubtodoDialog(SubtodoEntity subtodo) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<TodoBloc>(),
        child: AddSubtodoDialog(
          todoId: currentTodo.id!,
          subtodo: subtodo,
        ),
      ),
    );
  }
}
