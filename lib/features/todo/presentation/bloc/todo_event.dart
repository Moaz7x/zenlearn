// lib/features/todo/presentation/bloc/todo_event.dart
import 'package:equatable/equatable.dart';
import 'package:zenlearn/features/todo/domain/entities/reminder_entity.dart';
import 'package:zenlearn/features/todo/domain/entities/subtodo_entity.dart';

import '../../domain/entities/todo_entity.dart';

final class AddReminderRequested extends TodoEvent {
  final ReminderEntity reminder;
  AddReminderRequested(this.reminder);

  @override
  List<Object?> get props => [reminder];
}

final class AddSubTodoRequested extends TodoEvent {
  final SubtodoEntity subTodo;
  AddSubTodoRequested(this.subTodo);

  @override
  List<Object?> get props => [subTodo];
}

final class AddTodoRequested extends TodoEvent {
  final TodoEntity todo;
  AddTodoRequested(this.todo);

  @override
  List<Object?> get props => [todo];
}

final class DeleteReminderRequested extends TodoEvent {
  // Needed to reload reminders after deletion
  final int reminderId;
  final int todoId;
  DeleteReminderRequested(this.reminderId, this.todoId);

  @override
  List<Object?> get props => [reminderId, todoId];
}

final class DeleteSubTodoRequested extends TodoEvent {
  // Added to reload subtodos after deletion
  final int subtodoId;
  final int todoId;
  DeleteSubTodoRequested(this.subtodoId, this.todoId);

  @override
  List<Object?> get props => [subtodoId, todoId];
}

class DeleteTodoRequested extends TodoEvent {
  final int todoId;
  DeleteTodoRequested(this.todoId);

  @override
  List<Object?> get props => [todoId];
}

final class LoadCompletedTodos extends TodoEvent {}

final class LoadDueDatedTodos extends TodoEvent {}

final class LoadFilteredTodosByPriorityAll extends TodoEvent {
  final int priority;
  LoadFilteredTodosByPriorityAll(this.priority);
  @override
  List<Object?> get props => [priority];
}
final class LoadFilteredTodosByPriorityCompleated extends TodoEvent {
  final int priority;
  LoadFilteredTodosByPriorityCompleated(this.priority);
  @override
  List<Object?> get props => [priority];
}
final class LoadFilteredTodosByPriorityDueDated extends TodoEvent {
  final int priority;
  LoadFilteredTodosByPriorityDueDated(this.priority);
  @override
  List<Object?> get props => [priority];
}

final class LoadReminders extends TodoEvent {
  final int todoId;
  LoadReminders(this.todoId);

  @override
  List<Object?> get props => [todoId];
}

class LoadSubTodos extends TodoEvent {
  final int todoId;
  LoadSubTodos(this.todoId);

  @override
  List<Object?> get props => [todoId];
}

final class LoadTodos extends TodoEvent {}

final class SelectTodoDueDateEvent extends TodoEvent {
  final DateTime dueDate;
  SelectTodoDueDateEvent(this.dueDate);
  @override
  List<Object?> get props => [dueDate];
}

abstract class TodoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ToggleSubTodoCompletion extends TodoEvent {
  // Added to reload subtodos after toggle
  final int subtodoId;
  final int todoId;
  ToggleSubTodoCompletion(this.subtodoId, this.todoId);

  @override
  List<Object?> get props => [subtodoId, todoId];
}

class ToggleTodoCompletion extends TodoEvent {
  final int todoId;
  ToggleTodoCompletion(this.todoId);

  @override
  List<Object?> get props => [todoId];
}

final class UpdateReminderDateTime extends TodoEvent {
  final DateTime newDateTime;
  UpdateReminderDateTime(this.newDateTime);

  @override
  List<Object?> get props => [newDateTime];
}

class UpdateReminderRequested extends TodoEvent {
  final ReminderEntity reminder;
  UpdateReminderRequested(this.reminder);

  @override
  List<Object?> get props => [reminder];
}

class UpdateSubtodoCompletionStatus extends TodoEvent {
  final int todoId;
  final int subtodoId;
  final bool isCompleted;

  UpdateSubtodoCompletionStatus({
    required this.todoId,
    required this.subtodoId,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [todoId, subtodoId, isCompleted];
}

class UpdateSubTodoRequested extends TodoEvent {
  final SubtodoEntity subTodo;
  UpdateSubTodoRequested(this.subTodo);

  @override
  List<Object?> get props => [subTodo];
}

final class UpdateTodoCompletionStatus extends TodoEvent {
  final TodoEntity todo;

  UpdateTodoCompletionStatus(this.todo);

  @override
  List<Object?> get props => [todo];
}

final class UpdateTodoDueDate extends TodoEvent {
  final int todoId;
  final DateTime? dueDate;
  UpdateTodoDueDate(this.todoId, this.dueDate);

  @override
  List<Object?> get props => [todoId, dueDate];
}

final class UpdateTodoRequested extends TodoEvent {
  final TodoEntity todo;
  UpdateTodoRequested(this.todo);

  @override
  List<Object?> get props => [todo];
}
