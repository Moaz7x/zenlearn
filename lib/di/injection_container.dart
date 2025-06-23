// injection_container\n// Created: 2025-05-19\n\n
// lib/core/di/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zenlearn/features/todo/domain/usecases/add_reminder.dart';
import 'package:zenlearn/features/todo/domain/usecases/add_subtodo.dart';
import 'package:zenlearn/features/todo/domain/usecases/delete_reminder.dart';
import 'package:zenlearn/features/todo/domain/usecases/delete_subtodo.dart';
import 'package:zenlearn/features/todo/domain/usecases/filter_todos_usecase.dart';
import 'package:zenlearn/features/todo/domain/usecases/get_completed_todos.dart';
import 'package:zenlearn/features/todo/domain/usecases/get_duedated_todos.dart';
import 'package:zenlearn/features/todo/domain/usecases/load_reminders.dart';
import 'package:zenlearn/features/todo/domain/usecases/load_subtodos.dart';
import 'package:zenlearn/features/todo/domain/usecases/toggle_subtodo_compleation.dart';
import 'package:zenlearn/features/todo/domain/usecases/update_reminder.dart';
import 'package:zenlearn/features/todo/domain/usecases/update_subtodo.dart';

import '../features/todo/data/datasources/todo_local_datasource.dart';
import '../features/todo/data/models/reminder_model.dart';
import '../features/todo/data/models/subtodo_model.dart';
import '../features/todo/data/models/todo_model.dart';
import '../features/todo/data/repositories/todo_repository_impl.dart';
import '../features/todo/domain/repositories/todo_repository.dart';
import '../features/todo/domain/usecases/add_todo.dart';
import '../features/todo/domain/usecases/delete_todo.dart';
import '../features/todo/domain/usecases/get_all_todos.dart';
import '../features/todo/domain/usecases/toggle_todo_completion.dart';
import '../features/todo/domain/usecases/update_todo.dart';
import '../features/todo/presentation/bloc/todo_bloc.dart';

final sl = GetIt.instance; // Service Locator

Future<void> init() async {
  // Initialize Isar database
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [TodoModelSchema, SubtodoModelSchema, ReminderModelSchema],
    directory: dir.path,
  );

  // Register Isar instance
  sl.registerLazySingleton<Isar>(() => isar);

  // Data sources
  sl.registerLazySingleton<TodoLocalDataSource>(
    () => TodoLocalDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllTodos(sl()));
  sl.registerLazySingleton(() => AddTodo(sl()));
  sl.registerLazySingleton(() => UpdateTodo(sl()));
  sl.registerLazySingleton(() => DeleteTodo(sl()));
  sl.registerLazySingleton(() => ToggleTodoCompletionUseCase(sl()));
  sl.registerLazySingleton(() => LoadSubtodos(sl()));
  sl.registerLazySingleton(() => AddSubTodo(sl()));
  sl.registerLazySingleton(() => DeleteSubTodo(sl()));
  sl.registerLazySingleton(() => UpdateSubTodo(sl()));
  sl.registerLazySingleton(() => ToggleSubTodoCompletionUseCase(sl()));
  sl.registerLazySingleton(() => AddReminder(sl()));
  sl.registerLazySingleton(() => DeleteReminder(sl()));
  sl.registerLazySingleton(() => UpdateReminder(sl()));
  sl.registerLazySingleton(() => LoadRemindersUseCase(sl()));
  sl.registerLazySingleton(() => GetAllCompletedTodos(sl()));
  sl.registerLazySingleton(() => GetAllDueDatedTodos(sl()));
  sl.registerLazySingleton(() => FilterTodosUsecaseAll(sl()));
  sl.registerLazySingleton(() => FilterTodosUsecaseCompleated(sl()));
  sl.registerLazySingleton(() => FilterTodosUsecaseDueDated(sl()));

  // BLoC
  sl.registerFactory(
    () => TodoBloc(
        getAllDueDatedTodosUseCase: sl(),
        filterTodosUsecaseAll: sl(),
        filterTodosUsecaseCompleated: sl(),
        filterTodosUsecaseDueDated: sl(),
        getAllTodos: sl(),
        getAllCompletedTodosUseCase: sl(),
        addTodo: sl(),
        updateTodo: sl(),
        deleteTodo: sl(),
        toggleTodoCompletion: sl(),
        loadSubtodos: sl(),
        addSubTodo: sl(),
        deleteSubTodo: sl(),
        addReminderuseCase: sl(),
        deleteReminderUsecase: sl(),
        loadRemindersUseCase: sl(),
        updateReminderUsecase: sl(),
        updateSubTodo: sl(),
        toggleSubTodoCompletionUseCase: sl()),
  );
}
