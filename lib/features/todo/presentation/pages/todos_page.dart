// lib/features/todo/presentation/pages/todo_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zenlearn/core/localization/app_localizations.dart';
import 'package:zenlearn/core/services/notification_services.dart';
import 'package:zenlearn/core/utils/snackbar_utils.dart';
import 'package:zenlearn/core/widgets/app_scaffold.dart';
import 'package:zenlearn/core/widgets/custom_dialog.dart';
import 'package:zenlearn/features/todo/domain/entities/todo_entity.dart';

import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../widgets/todo_tile.dart';
import 'edit_todo_page.dart';
import 'todo_detail_page.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  late TodoBloc _todoBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _todoBloc = BlocProvider.of<TodoBloc>(context);
    _todoBloc.add(LoadTodos());
  }
  

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppLocalizations.of(context).translate('todo'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _todoBloc.add(LoadTodos()),
        ),
        IconButton(
          icon: const Icon(Icons.notification_add),
          onPressed: () {
            NotiService().showNotification(body: 'body', title: 'title');
          },
        ),
        IconButton(
          icon: const Icon(Icons.schedule),
          onPressed: () {
            NotiService().showScheduledNotification(
                title: 'title 2',
                body: 'body 2',
                hour: DateTime.now().hour,
                minute: DateTime.now().minute + 1,
                id: 0);
          },
        ),
      ],
      body: BlocConsumer<TodoBloc, TodoState>(
        listenWhen: (previous, current) =>
            current is TodoError ||
            (current is TodoOperationSuccess && !current.message.contains('SubTodo')),
        listener: (context, state) {
          if (state is TodoError && !state.message.contains('SubTodo')) {
            context.showGlassSnackBar(
              message: state.message,
            );
          } else if (state is TodoOperationSuccess && !state.message.contains('SubTodo')) {
            context.showGlassSnackBar(
              message: state.message,
            );
          } else if (state is SubTodoLoaded) {}
        },
        buildWhen: (previous, current) =>
            current is TodoLoaded ||
            current is CompletedTodosLoaded ||
            current is DueDatedTodosLoaded ||
            current is TodoInitial ||
            current is SubTodoLoaded ||
            current is FilterTodosByPriorityStateAll ||
            current is FilterTodosByPriorityStateDueDated ||
            current is FilterTodosByPriorityStateCompleated ||
            current is TodoLoading,
        builder: (context, state) {
          if (state is TodoLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          // if (state is SubTodoLoaded) {
          //   context.read<TodoBloc>().add(LoadTodos());
          // }

          return PageView(
            onPageChanged: (index) {
              switch (index) {
                case 0:
                  _todoBloc.add(LoadTodos());
                  break;
                case 1:
                  _todoBloc.add(LoadCompletedTodos());
                  break;
                case 2:
                  _todoBloc.add(LoadDueDatedTodos());
                  break;
              }
            },
            children: [
              BlocBuilder<TodoBloc, TodoState>(
                builder: (context, state) {
                  List<TodoEntity> getTodos() {
                    if (state is TodoLoaded) {
                      return state.todos;
                    }
                    if (state is FilterTodosByPriorityStateAll) {
                      return state.todos;
                    } else {
                      return [];
                    }
                  }

                  return _todoListView(
                    title: 'All Todos',
                    onPressed1: () {
                      context.read<TodoBloc>().add(LoadFilteredTodosByPriorityAll(1));
                    },
                    onPressed2: () {
                      context.read<TodoBloc>().add(LoadFilteredTodosByPriorityAll(2));
                    },
                    onPressed3: () {
                      context.read<TodoBloc>().add(LoadFilteredTodosByPriorityAll(3));
                    },
                    todos: getTodos(),
                  );
                },
              ),
              BlocBuilder<TodoBloc, TodoState>(
                builder: (context, state) {
                  List<TodoEntity> getTodos() {
                    if (state is CompletedTodosLoaded) {
                      return state.todos;
                    }
                    if (state is FilterTodosByPriorityStateCompleated) {
                      return state.todos;
                    } else {
                      return [];
                    }
                  }

                  return _todoListView(
                    title: 'Completed',
                    onPressed1: () {
                      context.read<TodoBloc>().add(LoadFilteredTodosByPriorityCompleated(1));
                    },
                    onPressed2: () {
                      context.read<TodoBloc>().add(LoadFilteredTodosByPriorityCompleated(2));
                    },
                    onPressed3: () {
                      context.read<TodoBloc>().add(LoadFilteredTodosByPriorityCompleated(3));
                    },
                    todos: getTodos(),
                  );
                },
              ),
              BlocBuilder<TodoBloc, TodoState>(
                builder: (context, state) {
                  List<TodoEntity> getTodos() {
                    if (state is DueDatedTodosLoaded) {
                      return state.todos;
                    }
                    if (state is FilterTodosByPriorityStateDueDated) {
                      return state.todos;
                    } else {
                      return [];
                    }
                  }

                  return _todoListView(
                    title: 'Due Dated',
                    onPressed1: () {
                      context.read<TodoBloc>().add(LoadFilteredTodosByPriorityDueDated(1));
                    },
                    onPressed2: () {
                      context.read<TodoBloc>().add(LoadFilteredTodosByPriorityDueDated(2));
                    },
                    onPressed3: () {
                      context.read<TodoBloc>().add(LoadFilteredTodosByPriorityDueDated(3));
                    },
                    todos: getTodos(),
                  );
                },
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => _showAddTodoDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
   

  @override
  void initState() {
    super.initState();
  }

 

  void _showAddTodoDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TodoBloc>(),
          child: const EditTodoPage(
            todo: null,
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int todoId, String todoTitle) {
    showDialog(
      context: context,
      builder: (_) => GlassDialog(
          content: Column(
        children: [
          const Text('Delete Todo'),
          const SizedBox(
            height: 40,
          ),
          Text('Are you sure you want to delete "$todoTitle"?'),
          Wrap(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  context.read<TodoBloc>().add(DeleteTodoRequested(todoId));
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

  Widget _todoListView({
    required String title,
    required List<TodoEntity> todos,
    required void Function() onPressed1,
    required void Function() onPressed2,
    required void Function() onPressed3,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Priority : '),
              Wrap(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      onPressed1();
                    },
                    style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.blueAccent)),
                    child: const Text('Low'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      onPressed2();
                    },
                    style:
                        const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.orange)),
                    child: const Text('Mid'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      onPressed3();
                    },
                    style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.pink)),
                    child: const Text('High'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          if (todos.isEmpty)
            Center(
              child: Column(
                children: [
                  const Icon(Icons.inbox_rounded, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    'No todos found.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final todo = todos[index];
                final bloc = _todoBloc;
                return TodoTile(
                  todo: todo,
                  onDelete: () => _showDeleteDialog(context, todo.id!, todo.title),
                  onEdit: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditTodoPage(todo: todo),
                      ),
                    );
                    if (mounted) {
                      _todoBloc.add(LoadTodos());
                    }
                  },
                  onToggle: () {
                    if (mounted) {
                      bloc.add(ToggleTodoCompletion(todo.id!));
                    }
                  },
                  onView: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TodoDetailPage(todo: todo),
                      ),
                    );
                    if (mounted) {
                      _todoBloc.add(LoadTodos());
                    }
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
