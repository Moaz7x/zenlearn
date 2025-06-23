import 'package:equatable/equatable.dart';

import '../../domain/entities/reminder_entity.dart';
import '../../domain/entities/subtodo_entity.dart';
import '../../domain/entities/todo_entity.dart';

class CompletedTodosLoaded extends TodoState {
  final List<TodoEntity> todos;
  CompletedTodosLoaded(this.todos);

  @override
  List<Object?> get props => [todos];
}
class FilterTodosByPriorityStateAll extends TodoState {
  final List<TodoEntity> todos;
  FilterTodosByPriorityStateAll(this.todos);

  @override
  List<Object?> get props => [todos];
}
class FilterTodosByPriorityStateCompleated extends TodoState {
  final List<TodoEntity> todos;
  FilterTodosByPriorityStateCompleated(this.todos);

  @override
  List<Object?> get props => [todos];
}
class FilterTodosByPriorityStateDueDated extends TodoState {
  final List<TodoEntity> todos;
  FilterTodosByPriorityStateDueDated(this.todos);

  @override
  List<Object?> get props => [todos];
}

class DueDatedTodosLoaded extends TodoState {
  final List<TodoEntity> todos;
  DueDatedTodosLoaded(this.todos);

  @override
  List<Object?> get props => [todos];
}

class ReminderDateTimeUpdated extends TodoState {
  final DateTime newDateTime;
  ReminderDateTimeUpdated(this.newDateTime);

  @override
  List<Object?> get props => [newDateTime];
}

// Add to todo_state.dart
class RemindersLoaded extends TodoState {
  final List<ReminderEntity> reminders;
  RemindersLoaded(this.reminders);

  @override
  List<Object?> get props => [reminders];
}

class RemindersLoading extends TodoState {}

class SubTodoLoaded extends TodoState {
  final List<SubtodoEntity> todos;
  SubTodoLoaded(this.todos);

  @override
  List<Object?> get props => [todos];
}

class SubTodoLoading extends TodoState {}

class TodoError extends TodoState {
  final String message;
  TodoError(this.message);

  @override
  List<Object?> get props => [message];
}

class TodoInitial extends TodoState {}

class TodoLoaded extends TodoState {
  final List<TodoEntity> todos;
  TodoLoaded(this.todos);

  @override
  List<Object?> get props => [todos];
}

class TodoLoading extends TodoState {}

class TodoOperationSuccess extends TodoState {
  final String message;
  TodoOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

abstract class TodoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SelectedDateChanged extends TodoState {
  final DateTime dueDate;
  SelectedDateChanged(this.dueDate);
  @override
  List<Object?> get props => [dueDate];
}
