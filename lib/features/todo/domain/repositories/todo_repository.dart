import 'package:zenlearn/features/todo/domain/entities/reminder_entity.dart';
import 'package:zenlearn/features/todo/domain/entities/subtodo_entity.dart';

import '../entities/todo_entity.dart';

abstract class TodoRepository {
  Future<void> addReminder(ReminderEntity reminder);
  Future<void> addSubTodo(SubtodoEntity subTodo);
  Future<void> addTodo(TodoEntity todo);
  Future<void> deleteReminder(int id);
  Future<void> deleteSubTodo(int id);
  Future<void> deleteTodo(int id);
  Future<List<ReminderEntity>> getAllReminders(int todoId);
  Future<List<SubtodoEntity>> getAllSubTodos(int todoId);
  Future<List<TodoEntity>> getAllTodos();
  Future<List<TodoEntity>> getAllCompletedTodos();
  Future<List<TodoEntity>> getAllDueDatedTodos();
  Future<List<TodoEntity>> filterTodosByPriorityAll(int priority);
  Future<List<TodoEntity>> filterTodosByPriorityCompleted(int priority);
  Future<List<TodoEntity>> filterTodosByPriorityDueDated(int priority);
  // Future<List<TodoEntity>> getAllDueDatedTodos();
  Future<ReminderEntity> getReminderById(int id);
  Future<TodoEntity?> getTodoById(int id);
  Future<void> toggleSubTodoCompletion(int todoId);
  Future<void> toggleTodoCompletion(int id);
  Future<void> updateReminder(ReminderEntity reminder);
  Future<void> updateSubTodo(SubtodoEntity subTodo);
  Future<void> updateTodo(TodoEntity todo);
}
