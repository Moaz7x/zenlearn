// lib/features/todo/presentation/bloc/todo_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zenlearn/core/services/notification_services.dart';
import 'package:zenlearn/features/todo/domain/entities/todo_entity.dart';
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

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/reminder_entity.dart';
import '../../domain/entities/subtodo_entity.dart';
import '../../domain/usecases/add_todo.dart';
import '../../domain/usecases/delete_todo.dart';
import '../../domain/usecases/get_all_todos.dart';
import '../../domain/usecases/toggle_todo_completion.dart';
import '../../domain/usecases/update_todo.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final GetAllTodos getAllTodos;
  final LoadRemindersUseCase loadRemindersUseCase;
  final AddReminder addReminderuseCase;
  final DeleteReminder deleteReminderUsecase;
  final UpdateReminder updateReminderUsecase;
  final AddTodo addTodo;
  final UpdateTodo updateTodo;
  final DeleteTodo deleteTodo;
  final GetAllCompletedTodos getAllCompletedTodosUseCase;
  final GetAllDueDatedTodos getAllDueDatedTodosUseCase;
  final ToggleTodoCompletionUseCase toggleTodoCompletion;
  final LoadSubtodos loadSubtodos;
  final AddSubTodo addSubTodo;
  final DeleteSubTodo deleteSubTodo;
  final UpdateSubTodo updateSubTodo;
  final ToggleSubTodoCompletionUseCase toggleSubTodoCompletionUseCase;
  final FilterTodosUsecaseAll filterTodosUsecaseAll;
  final FilterTodosUsecaseCompleated filterTodosUsecaseCompleated;
  final FilterTodosUsecaseDueDated filterTodosUsecaseDueDated;
  TodoBloc({
    required this.filterTodosUsecaseAll,
    required this.filterTodosUsecaseCompleated,
    required this.filterTodosUsecaseDueDated,
    required this.getAllCompletedTodosUseCase,
    required this.getAllDueDatedTodosUseCase,
    required this.getAllTodos,
    required this.addSubTodo,
    required this.updateSubTodo,
    required this.deleteSubTodo,
    required this.loadSubtodos,
    required this.addTodo,
    required this.updateTodo,
    required this.deleteTodo,
    required this.toggleTodoCompletion,
    required this.toggleSubTodoCompletionUseCase,
    required this.loadRemindersUseCase,
    required this.addReminderuseCase,
    required this.deleteReminderUsecase,
    required this.updateReminderUsecase,
  }) : super(TodoInitial()) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodoRequested>(_onAddTodo);
    on<UpdateTodoRequested>(_onUpdateTodo);
    on<DeleteTodoRequested>(_onDeleteTodo);
    on<ToggleTodoCompletion>(_onToggleTodoCompletion);
    on<LoadSubTodos>(_onLoadSubTodos);
    on<AddSubTodoRequested>(_onAddSubTodoRequested);
    on<DeleteSubTodoRequested>(_onDeleteSubTodoRequested);
    on<UpdateSubTodoRequested>(_onUpdateSubTodoRequested);
    on<ToggleSubTodoCompletion>(_onToggleSubTodoCompletion);
    on<LoadReminders>(_onLoadReminders);
    on<AddReminderRequested>(_onAddReminderRequested);
    on<DeleteReminderRequested>(_onDeleteReminderRequested);
    on<UpdateReminderRequested>(_onUpdateReminderRequested);
    on<UpdateTodoCompletionStatus>(_onUpdateTodoCompletionStatus);
    on<UpdateTodoDueDate>(_onUpdateTodoDueDate);
    on<UpdateReminderDateTime>(_onUpdateReminderDateTime);
    on<UpdateSubtodoCompletionStatus>(_onUpdateSubtodoCompletionStatus);
    on<LoadCompletedTodos>(_onCompletedTodosLoaded);
    on<LoadDueDatedTodos>(_onDueDatedTodosLoaded);
    on<SelectTodoDueDateEvent>(_onSelectDueDateEvent);
    on<LoadFilteredTodosByPriorityAll>(_onLoadFilterdTodosByPriority);
    on<LoadFilteredTodosByPriorityCompleated>(_onLoadFilterdTodosByPriorityCompleated);
    on<LoadFilteredTodosByPriorityDueDated>(_onLoadFilterdTodosByPriorityDueDated);
  }
  Future<void> _cancelReminderNotification(int reminderId) async {
    await NotiService().cancilAllNotification(reminderId);
  }

  Future<void> _onAddReminderRequested(AddReminderRequested event, Emitter<TodoState> emit) async {
    try {
      await addReminderuseCase(event.reminder);

      // Schedule notification
      await _scheduleReminderNotification(event.reminder);

      // Reload reminders
      final reminders = await loadRemindersUseCase(event.reminder.todoId);
      emit(RemindersLoaded(reminders));
      emit(TodoOperationSuccess('Reminder added successfully'));
    } catch (e) {
      emit(TodoError('Failed to add reminder: ${e.toString()}'));
    }
  }

  Future<void> _onAddSubTodoRequested(AddSubTodoRequested event, Emitter<TodoState> emit) async {
    try {
      await addSubTodo(event.subTodo);
      // Reload subtodos immediately after adding
      final subtodos = await loadSubtodos(event.subTodo.todoId);
      emit(SubTodoLoaded(subtodos));
      emit(TodoOperationSuccess('SubTodo Added Successfully'));
    } catch (e) {
      emit(TodoError('Failed to add sub todo: ${e.toString()}'));
    }
  }

  Future<void> _onAddTodo(AddTodoRequested event, Emitter<TodoState> emit) async {
    try {
      await addTodo(event.todo);
      // Reload todos immediately after adding
      final todos = await getAllTodos(NoParams());
      emit(TodoLoaded(todos));
      emit(TodoOperationSuccess('Todo added successfully'));
      await _scheduleTodoNotification(event.todo);
    } catch (e) {
      emit(TodoError('Failed to add todo: ${e.toString()}'));
    }
  }

  Future<void> _onCompletedTodosLoaded(LoadCompletedTodos event, Emitter<TodoState> emit) async {
    try {
      final todos = await getAllCompletedTodosUseCase(NoParams());
      emit(CompletedTodosLoaded(todos));
    } catch (e) {
      emit(TodoError('Loading Completed Todos Error $e'));
    }
  }

  Future<void> _onDeleteReminderRequested(
      DeleteReminderRequested event, Emitter<TodoState> emit) async {
    try {
      await deleteReminderUsecase(event.reminderId);

      // Cancel notification
      await _cancelReminderNotification(event.reminderId);

      // Reload reminders
      final reminders = await loadRemindersUseCase(event.todoId);
      emit(RemindersLoaded(reminders));
      emit(TodoOperationSuccess('Reminder deleted successfully'));
    } catch (e) {
      emit(TodoError('Failed to delete reminder: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteSubTodoRequested(
      DeleteSubTodoRequested event, Emitter<TodoState> emit) async {
    try {
      await deleteSubTodo(event.subtodoId);
      // Reload subtodos immediately after deleting
      final subtodos = await loadSubtodos(event.todoId);
      emit(SubTodoLoaded(subtodos));
      emit(TodoOperationSuccess('Successfully Deleted subtodo'));
    } catch (e) {
      emit(TodoError('Failed to delete subtodo: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteTodo(DeleteTodoRequested event, Emitter<TodoState> emit) async {
    try {
      await deleteTodo(event.todoId);
      // Reload todos immediately after deleting
      final todos = await getAllTodos(NoParams());
      emit(TodoLoaded(todos));
      emit(TodoOperationSuccess('Todo deleted successfully'));
    } catch (e) {
      emit(TodoError('Failed to delete todo: ${e.toString()}'));
    }
  }

  Future<void> _onDueDatedTodosLoaded(LoadDueDatedTodos event, Emitter<TodoState> emit) async {
    try {
      final todos = await getAllDueDatedTodosUseCase(NoParams());
      emit(DueDatedTodosLoaded(todos));
    } catch (e) {
      emit(TodoError('Loading DueDated Todos Error $e'));
    }
  }

  Future<void> _onLoadFilterdTodosByPriority(
      LoadFilteredTodosByPriorityAll event, Emitter<TodoState> emit) async {
    try {
      final todos = await filterTodosUsecaseAll(event.priority);
      emit(FilterTodosByPriorityStateAll(todos));
    } catch (e) {
      emit(TodoError('Loading Filterd Todos by priority Error $e'));
    }
  }

  Future<void> _onLoadFilterdTodosByPriorityCompleated(
      LoadFilteredTodosByPriorityCompleated event, Emitter<TodoState> emit) async {
    try {
      final todos = await filterTodosUsecaseCompleated(event.priority);
      emit(FilterTodosByPriorityStateCompleated(todos));
    } catch (e) {
      emit(TodoError('Loading Filterd Todos by priority Error $e'));
    }
  }

  Future<void> _onLoadFilterdTodosByPriorityDueDated(
      LoadFilteredTodosByPriorityDueDated event, Emitter<TodoState> emit) async {
    try {
      final todos = await filterTodosUsecaseDueDated(event.priority);
      emit(FilterTodosByPriorityStateDueDated(todos));
    } catch (e) {
      emit(TodoError('Loading Filterd Todos by priority Error $e'));
    }
  }

  // Add these methods to TodoBloc
  Future<void> _onLoadReminders(LoadReminders event, Emitter<TodoState> emit) async {
    try {
      final reminders = await loadRemindersUseCase(event.todoId);
      emit(RemindersLoaded(reminders));
    } catch (e) {
      emit(TodoError('Failed to load reminders: ${e.toString()}'));
    }
  }

  Future<void> _onLoadSubTodos(LoadSubTodos event, Emitter<TodoState> emit) async {
    // Don't emit loading state to avoid overriding current todo state

    try {
      final subtodos = await loadSubtodos(event.todoId);
      emit(SubTodoLoaded(subtodos));
    } catch (e) {
      emit(TodoError('Failed to load SubTodos: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    try {
      final todos = await getAllTodos(NoParams());
      emit(TodoLoaded(todos));
    } catch (e) {
      emit(TodoError('Failed to load todos: ${e.toString()}'));
    }
  }

  Future<void> _onSelectDueDateEvent(SelectTodoDueDateEvent event, Emitter<TodoState> emit) async {
    emit(SelectedDateChanged(event.dueDate));
  }

  Future<void> _onToggleSubTodoCompletion(
      ToggleSubTodoCompletion event, Emitter<TodoState> emit) async {
    try {
      await toggleSubTodoCompletionUseCase(
        event.todoId,
      );
      // Reload subtodos immediately after toggling
      final subtodos = await loadSubtodos(event.todoId);
      emit(SubTodoLoaded(subtodos));
      // Remove the recursive call
      emit(TodoOperationSuccess('SubTodo status updated'));
    } catch (e) {
      emit(TodoError('Failed to toggle sub todo completion: ${e.toString()}'));
    }
  }

  Future<void> _onToggleTodoCompletion(ToggleTodoCompletion event, Emitter<TodoState> emit) async {
    try {
      await toggleTodoCompletion(event.todoId);
      // Reload todos immediately after toggling
      final todos = await getAllTodos(NoParams());

      emit(TodoLoaded(todos));
      emit(TodoOperationSuccess('Todo status updated'));
      add(LoadTodos());
    } catch (e) {
      emit(TodoError('Failed to toggle todo completion: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateReminderDateTime(
      UpdateReminderDateTime event, Emitter<TodoState> emit) async {
    // This event is primarily for local UI updates in the dialog.
    // The actual reminder update happens when _saveReminder is called.
    // We just need to emit a state that the dialog can listen to to update its UI.
    emit(ReminderDateTimeUpdated(event.newDateTime));
  }

  Future<void> _onUpdateReminderRequested(
      UpdateReminderRequested event, Emitter<TodoState> emit) async {
    try {
      await updateReminderUsecase(event.reminder);

      // Reschedule notification
      await _cancelReminderNotification(event.reminder.id!);
      await _scheduleReminderNotification(event.reminder);

      // Reload reminders
      final reminders = await loadRemindersUseCase(event.reminder.todoId);
      emit(RemindersLoaded(reminders));
      emit(TodoOperationSuccess('Reminder updated successfully'));
    } catch (e) {
      emit(TodoError('Failed to update reminder: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateSubtodoCompletionStatus(
      UpdateSubtodoCompletionStatus event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final currentTodos = (state as TodoLoaded).todos;
      final todoIndex = currentTodos.indexWhere((todo) => todo.id == event.todoId);

      if (todoIndex != -1) {
        final todoToUpdate = currentTodos[todoIndex];
        final subtodoIndex =
            todoToUpdate.subtodos.indexWhere((subtodo) => subtodo.id == event.subtodoId);

        if (subtodoIndex != -1) {
          final updatedSubtodos = List<SubtodoEntity>.from(todoToUpdate.subtodos);
          updatedSubtodos[subtodoIndex] =
              updatedSubtodos[subtodoIndex].copyWith(isCompleted: event.isCompleted);

          final updatedTodo = todoToUpdate.copyWith(subtodos: updatedSubtodos);
          await updateTodo(updatedTodo);
          emit(TodoLoaded(
              currentTodos.map((todo) => todo.id == updatedTodo.id ? updatedTodo : todo).toList()));
          emit(TodoOperationSuccess('Subtodo completion status updated successfully!'));
        }
      }
    }
  }

  Future<void> _onUpdateSubTodoRequested(
      UpdateSubTodoRequested event, Emitter<TodoState> emit) async {
    try {
      await updateSubTodo(event.subTodo);
      // Reload subtodos immediately after updating
      final subtodos = await loadSubtodos(event.subTodo.todoId);
      emit(SubTodoLoaded(subtodos));
      emit(TodoOperationSuccess('SubTodo updated successfully'));
    } catch (e) {
      emit(TodoError('Failed to update subtodo: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTodo(UpdateTodoRequested event, Emitter<TodoState> emit) async {
    try {
      await updateTodo(event.todo);
      // Reload todos immediately after updating
      final todos = await getAllTodos(NoParams());
      emit(TodoLoaded(todos));
      emit(TodoOperationSuccess('Todo updated successfully'));
    } catch (e) {
      emit(TodoError('Failed to update todo: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTodoCompletionStatus(
      UpdateTodoCompletionStatus event, Emitter<TodoState> emit) async {
    try {
      final todo = event.todo.copyWith(isCompleted: !event.todo.isCompleted);

      await updateTodo(todo);
      final todos = await getAllTodos(NoParams());
      emit(TodoLoaded(todos));
      emit(TodoOperationSuccess('Todo completion status updated'));
    } catch (e) {
      emit(TodoError('Failed to update todo completion status: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTodoDueDate(UpdateTodoDueDate event, Emitter<TodoState> emit) async {
    try {
      final currentTodo = (state as TodoLoaded).todos.firstWhere((todo) => todo.id == event.todoId);
      final updatedTodo = currentTodo.copyWith(dueDate: event.dueDate);
      await updateTodo(updatedTodo);
      final todos = await getAllTodos(NoParams());
      emit(TodoLoaded(todos));
      emit(TodoOperationSuccess('Todo due date updated'));
    } catch (e) {
      emit(TodoError('Failed to update todo due date: ${e.toString()}'));
    }
  }

  Future<void> _scheduleReminderNotification(ReminderEntity reminder) async {
    // Also register with Workmanager for reliability
    await NotiService().showScheduledNotification(
      title: 'Todo Reminder',
      body: reminder.message,
      hour: reminder.reminderTime.hour,
      minute: reminder.reminderTime.minute,
    );
    return;
  }

  Future<void> _scheduleTodoNotification(TodoEntity todo) async {
    await NotiService().showScheduledNotification(
        title: todo.title,
        body: todo.description,
        hour: todo.dueDate!.hour,
        minute: todo.dueDate!.minute);
  }
}
