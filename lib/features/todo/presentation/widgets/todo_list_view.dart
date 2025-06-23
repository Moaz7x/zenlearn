import 'package:flutter/material.dart';
import 'package:zenlearn/features/todo/domain/entities/todo_entity.dart';
import 'package:zenlearn/core/localization/app_localizations.dart'; // Assuming this path

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

    return RefreshIndicator( // Added RefreshIndicator for pull-to-refresh UX
      onRefresh: () async {
        onRefresh();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title, // Displays the current filter category (e.g., "Completed", "Due Dated")
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        if (title == localizations.translate('all_todos'))
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              localizations.translate('tap_add_to_create'),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: InkWell( // Added InkWell for better tap feedback
                          onTap: () => onEditTodo(todo), // Tap to edit
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: todo.isCompleted,
                                  onChanged: (bool? value) {
                                    onToggleCompletion(todo);
                                  },
                                  activeColor: Theme.of(context).primaryColor,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        todo.title,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                                              color: todo.isCompleted ? Colors.grey : null,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (todo.description != null && todo.description!.isNotEmpty)
                                        Text(
                                          todo.description!,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                                                color: Colors.grey,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      if (todo.dueDate != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            '${localizations.translate('due')}: ${todo.dueDate!.toLocal().toString().split(' ')[0]}',
                                            style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                                          ),
                                        ),
                                      if (todo.priority != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            '${localizations.translate('priority')}: ${todo.priority}',
                                            style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => showDeleteDialog(context, todo.id!, todo.title),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
