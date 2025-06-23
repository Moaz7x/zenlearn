import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zenlearn/core/localization/app_localizations.dart';
import 'package:zenlearn/core/utils/snackbar_utils.dart';
import 'package:zenlearn/core/widgets/app_scaffold.dart';
import 'package:zenlearn/features/todo/domain/entities/todo_entity.dart';

import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../widgets/delete_todo_dialog.dart';
import '../widgets/todo_list_view.dart'; // Import the new TodoListView
import 'edit_todo_page.dart'; // Assuming this is the page for adding/editing todos

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  late TodoBloc _todoBloc;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AppScaffold(
      title: localizations.translate('todo_list'),
      body: BlocConsumer<TodoBloc, TodoState>(
        listenWhen: (previous, current) =>
            current is TodoError ||
            (current is TodoOperationSuccess && !current.message.contains('SubTodo')),
        listener: (context, state) {
          if (state is TodoError && !state.message.contains('SubTodo')) {
            context.showGlassSnackBar(
              message: state.message,
              // isError: true, // Indicate error visually
            );
          } else if (state is TodoOperationSuccess && !state.message.contains('SubTodo')) {
            context.showGlassSnackBar(
              message: state.message,
              // isError: false, // Indicate success visually
            );
          }
          // SubTodoLoaded is handled by specific BlocBuilders, no global snackbar needed
        },
        buildWhen: (previous, current) =>
            current is TodoLoaded ||
            current is CompletedTodosLoaded ||
            current is DueDatedTodosLoaded ||
            current is TodoInitial ||
            current
                is SubTodoLoaded || // Though SubTodoLoaded might not affect the main list view directly
            current is FilterTodosByPriorityStateAll ||
            current is FilterTodosByPriorityStateDueDated ||
            current is FilterTodosByPriorityStateCompleated ||
            current is TodoLoading,
        builder: (context, state) {
          return PageView(
            controller: _pageController,
            onPageChanged: (index) {
              // This is the UI control for the main filters:
              // When the user swipes pages, the corresponding BLoC event is dispatched
              // to load the correct set of todos (All, Completed, or Due Dated).
              switch (index) {
                case 0:
                  _todoBloc.add(LoadTodos()); // Load All Todos for the first tab
                  break;
                case 1:
                  _todoBloc.add(LoadCompletedTodos()); // Load Completed Todos for the second tab
                  break;
                case 2:
                  _todoBloc.add(LoadDueDatedTodos()); // Load Due Dated Todos for the third tab
                  break;
                default:
                  _todoBloc.add(LoadTodos());
              }
            },
            children: [
              // Page 1: All Todos (UI for displaying all todos)
              BlocBuilder<TodoBloc, TodoState>(
                buildWhen: (previous, current) =>
                    current is TodoLoaded || current is FilterTodosByPriorityStateAll,
                builder: (context, state) {
                  List<TodoEntity> todos = [];
                  if (state is TodoLoaded) {
                    todos = state.todos;
                  } else if (state is FilterTodosByPriorityStateAll) {
                    todos = state.todos;
                  }
                  return TodoListView(
                    title: localizations.translate('all_todos'),
                    todos: todos,
                    showDeleteDialog: _showDeleteDialog,
                    onPressedPriority1: () => _todoBloc.add(LoadFilteredTodosByPriorityAll(1)),
                    onPressedPriority2: () => _todoBloc.add(LoadFilteredTodosByPriorityAll(2)),
                    onPressedPriority3: () => _todoBloc.add(LoadFilteredTodosByPriorityAll(3)),
                    onToggleCompletion: (todo) => _todoBloc.add(ToggleTodoCompletion(todo.id!)),
                    onEditTodo: (todo) => _navigateToEditTodoPage(context, todo),
                    onRefresh: () => _todoBloc.add(LoadTodos()),
                  );
                },
              ),

              // Page 2: Completed Todos (UI for displaying only completed todos)
              BlocBuilder<TodoBloc, TodoState>(
                buildWhen: (previous, current) =>
                    current is CompletedTodosLoaded ||
                    current is FilterTodosByPriorityStateCompleated,
                builder: (context, state) {
                  List<TodoEntity> todos = [];
                  if (state is CompletedTodosLoaded) {
                    todos = state.todos;
                  } else if (state is FilterTodosByPriorityStateCompleated) {
                    todos = state.todos;
                  }
                  return TodoListView(
                    title: localizations.translate('completed_todos'), // Title indicates the filter
                    todos: todos, // This list contains only completed todos
                    showDeleteDialog: _showDeleteDialog,
                    onPressedPriority1: () =>
                        _todoBloc.add(LoadFilteredTodosByPriorityCompleated(1)),
                    onPressedPriority2: () =>
                        _todoBloc.add(LoadFilteredTodosByPriorityCompleated(2)),
                    onPressedPriority3: () =>
                        _todoBloc.add(LoadFilteredTodosByPriorityCompleated(3)),
                    onToggleCompletion: (todo) => _todoBloc.add(ToggleTodoCompletion(todo.id!)),
                    onEditTodo: (todo) => _navigateToEditTodoPage(context, todo),
                    onRefresh: () => _todoBloc.add(LoadCompletedTodos()),
                  );
                },
              ),

              // Page 3: Due Dated Todos (UI for displaying only due dated todos)
              BlocBuilder<TodoBloc, TodoState>(
                buildWhen: (previous, current) =>
                    current is DueDatedTodosLoaded || current is FilterTodosByPriorityStateDueDated,
                builder: (context, state) {
                  List<TodoEntity> todos = [];
                  if (state is DueDatedTodosLoaded) {
                    todos = state.todos;
                  } else if (state is FilterTodosByPriorityStateDueDated) {
                    todos = state.todos;
                  }
                  return TodoListView(
                    title: localizations.translate('due_dated_todos'), // Title indicates the filter
                    todos: todos, // This list contains only due dated todos
                    showDeleteDialog: _showDeleteDialog,
                    onPressedPriority1: () => _todoBloc.add(LoadFilteredTodosByPriorityDueDated(1)),
                    onPressedPriority2: () => _todoBloc.add(LoadFilteredTodosByPriorityDueDated(2)),
                    onPressedPriority3: () => _todoBloc.add(LoadFilteredTodosByPriorityDueDated(3)),
                    onToggleCompletion: (todo) => _todoBloc.add(ToggleTodoCompletion(todo.id!)),
                    onEditTodo: (todo) => _navigateToEditTodoPage(context, todo),
                    onRefresh: () => _todoBloc.add(LoadDueDatedTodos()),
                  );
                },
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => _navigateToAddTodoPage(context),
        tooltip: localizations.translate('add_new_todo'),
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize BLoC here to ensure context is fully available
    _todoBloc = BlocProvider.of<TodoBloc>(context);
    // Load initial todos when the page is first built or becomes active again
    // This loads the "All Todos" list for the first tab.
    _todoBloc.add(LoadTodos());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _todoBloc = BlocProvider.of<TodoBloc>(context);
    _todoBloc.add(LoadTodos());

    super.initState();
  }

  // Helper to navigate to Add Todo page
  void _navigateToAddTodoPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _todoBloc, // Pass the existing BLoC instance
          child: const EditTodoPage(
            todo: null, // Null indicates adding a new todo
          ),
        ),
      ),
    );
  }

  // Helper to navigate to Edit Todo page
  void _navigateToEditTodoPage(BuildContext context, TodoEntity todo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _todoBloc, // Pass the existing BLoC instance
          child: EditTodoPage(
            todo: todo, // Pass the todo to be edited
          ),
        ),
      ),
    );
  }

  // Helper to show delete confirmation dialog
  void _showDeleteDialog(BuildContext context, int todoId, String todoTitle) {
    showDeleteTodoDialog(context, todoId, todoTitle, () {
      _todoBloc.add(DeleteTodoRequested(todoId));
    });
  }
}
