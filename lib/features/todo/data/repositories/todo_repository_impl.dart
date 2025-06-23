import 'package:zenlearn/features/todo/data/models/reminder_model.dart';
import 'package:zenlearn/features/todo/data/models/subtodo_model.dart';
import 'package:zenlearn/features/todo/domain/entities/reminder_entity.dart';
import 'package:zenlearn/features/todo/domain/entities/subtodo_entity.dart';

import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_datasource.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource localDataSource;
  TodoRepositoryImpl(this.localDataSource);

  @override
  Future<void> addReminder(ReminderEntity reminder) async {
    final reminderModel = ReminderModel.fromEntity(reminder);
    await localDataSource.addReminder(reminderModel);
  }

  @override
  Future<void> addSubTodo(SubtodoEntity subTodo) async {
    final subTodoModel = SubtodoModel.fromEntity(subTodo);
    await localDataSource.addSubTodo(subTodoModel);
  }

  @override
  Future<void> addTodo(TodoEntity todo) async {
    final todoModel = TodoModel.fromEntity(todo);
    await localDataSource.addTodo(todoModel);
  }

  @override
  Future<void> deleteReminder(int id) async {
    await localDataSource.deleteReminder(id);
  }

  @override
  Future<void> deleteSubTodo(int id) async {
    await localDataSource.deleteSubTodo(id);
  }

  @override
  Future<void> deleteTodo(int id) async {
    await localDataSource.deleteTodo(id);
  }

  @override
  Future<List<TodoEntity>> filterTodosByPriorityAll(int priority) async {
    final todoModels = await localDataSource.filterTodosByPriorityAll(priority);
    return todoModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<TodoEntity>> filterTodosByPriorityCompleted(int priority) async {
    final todoModels = await localDataSource.filterTodosByPriorityCompleated(priority);
    return todoModels.map((todo) => todo.toEntity()).toList();
  }

  @override
  Future<List<TodoEntity>> filterTodosByPriorityDueDated(int priority) async {
    final todoModels = await localDataSource.filterTodosByPriorityDueDated(priority);
    return todoModels.map((todo) => todo.toEntity()).toList();
  }

  @override
  Future<List<TodoEntity>> getAllCompletedTodos() async {
    final todoModels = await localDataSource.getAllCompletedTodos();
    return todoModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<TodoEntity>> getAllDueDatedTodos() async {
    final todoModels = await localDataSource.getAllDueDatedTodos();
    return todoModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<ReminderEntity>> getAllReminders(int todoId) async {
    final todoReminders = await localDataSource.getAllReminders(todoId);
    return todoReminders.map((reminder) => reminder.toEntity()).toList();
  }

  @override
  Future<List<SubtodoEntity>> getAllSubTodos(int todoId) async {
    final todoModels = await localDataSource.getAllSubTodos(todoId);
    return todoModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<TodoEntity>> getAllTodos() async {
    final todoModels = await localDataSource.getAllTodos();
    return todoModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<ReminderEntity> getReminderById(int id) {
    throw UnimplementedError();
  }

  Future<SubtodoEntity?> getSubtodoById(int id) async {
    final subTodoModel = await localDataSource.getSubTodoById(id);
    return subTodoModel?.toEntity();
  }

  @override
  Future<TodoEntity?> getTodoById(int id) async {
    final todoModel = await localDataSource.getTodoById(id);
    return todoModel?.toEntity();
  }

  @override
  Future<void> toggleSubTodoCompletion(int id) async {
    final subTodo = await getSubtodoById(id);
    if (subTodo != null) {
      final updatedSubTodo = SubtodoEntity(
        id: subTodo.id, // <--- THIS IS THE CRUCIAL FIX: Ensure the existing ID is passed
        title: subTodo.title,
        isCompleted: !subTodo.isCompleted,
        todoId: subTodo.todoId,
      );
      return updateSubTodo(updatedSubTodo);
    }
  }

  @override
  Future<void> toggleTodoCompletion(int id) async {
    // This demonstrates how business logic can be implemented at the repository level
    final todo = await getTodoById(id);
    if (todo != null) {
      final updatedTodo = TodoEntity(
        id: todo.id,
        title: todo.title,
        description: todo.description,
        isCompleted: !todo.isCompleted, // Toggle the completion status
        createdAt: todo.createdAt,
        priority: todo.priority,
        dueDate: todo.dueDate,
        subtodos: todo.subtodos,
        reminders: todo.reminders,
      );
      await updateTodo(updatedTodo);
    }
  }

  @override
  Future<void> updateReminder(ReminderEntity reminder) async {
    final reminderModel = ReminderModel.fromEntity(reminder);
    await localDataSource.updateReminder(reminderModel);
  }

  @override
  Future<void> updateSubTodo(SubtodoEntity subTodo) async {
    final subTodoModel = SubtodoModel.fromEntity(subTodo);
    await localDataSource.updateSubTodo(subTodoModel);
  }

  @override
  Future<void> updateTodo(TodoEntity todo) async {
    final todoModel = TodoModel.fromEntity(todo);
    await localDataSource.updateTodo(todoModel);
  }
}
