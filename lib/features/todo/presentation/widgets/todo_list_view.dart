import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zenlearn/core/localization/app_localizations.dart'; // Assuming this path
import 'package:zenlearn/features/todo/domain/entities/todo_entity.dart';
import 'package:zenlearn/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:zenlearn/features/todo/presentation/bloc/todo_event.dart';
import 'package:zenlearn/features/todo/presentation/pages/edit_todo_page.dart';
import 'package:zenlearn/features/todo/presentation/pages/todo_detail_page.dart';
import 'package:zenlearn/features/todo/presentation/widgets/delete_todo_dialog.dart';
import 'package:zenlearn/features/todo/presentation/widgets/todo_tile.dart';

class TodoListView extends StatelessWidget {
  final String title; // e.g., "All Todos", "Completed", "Due Dated"
  final List<TodoEntity> todos;
  final Function(BuildContext, int, String) showDeleteDialog;
  final VoidCallback onPressedPriority1;
  final VoidCallback onPressedPriority2;
  final VoidCallback onPressedPriority3;
  final Function(TodoEntity) onToggleCompletion;
  final Function(TodoEntity) onEditTodo;
  final VoidCallback onRefresh; // Added for pull-to-refresh

  const TodoListView({
    super.key,
    required this.title,
    required this.todos,
    required this.showDeleteDialog,
    required this.onPressedPriority1,
    required this.onPressedPriority2,
    required this.onPressedPriority3,
    required this.onToggleCompletion,
    required this.onEditTodo,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return RefreshIndicator(
      // Added RefreshIndicator for pull-to-refresh UX
      onRefresh: () async {
        onRefresh();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title, // Displays the current filter category (e.g., "Completed", "Due Dated")
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        context.read<TodoBloc>().add(LoadTodos());
                      },
                      child: const Row(
                        children: [Text("Refresh"), Icon(Icons.refresh)],
                      ))
                ],
              )),
          // Priority Filter Buttons (secondary filter within each main category)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPressedPriority1,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100, // Example color
                    ),
                    child: Text(localizations.translate('priority_1')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPressedPriority2,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade100, // Example color
                    ),
                    child: Text(localizations.translate('priority_2')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPressedPriority3,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade100, // Example color
                    ),
                    child: Text(localizations.translate('priority_3')),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: todos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          localizations.translate('no_todos_yet'),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        if (title == localizations.translate('all_todos'))
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              localizations.translate('tap_add_to_create'),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.builder(
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        final todo = todos[index];
                        final todoBloc = context.read<TodoBloc>();
                        return TodoTile(
                          todo: todo,
                          onDelete: () => showDeleteTodoDialog(context, todo.id!, todo.title, () {
                            todoBloc.add(DeleteTodoRequested(todo.id!));
                          }),
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditTodoPage(
                                  todo: todo,
                                ),
                              ),
                            );
                          },
                          onToggle: () {
                            todoBloc.add(ToggleTodoCompletion(todo.id!));
                          },
                          onView: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TodoDetailPage(
                                  todo: todo,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
