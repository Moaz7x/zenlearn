// lib/features/todo/data/datasources/todo_local_datasource.dart
import 'package:isar/isar.dart';

import '../models/reminder_model.dart';
import '../models/subtodo_model.dart';
import '../models/todo_model.dart';

abstract class TodoLocalDataSource {
  Future<void> addReminder(ReminderModel reminder);
  Future<void> addSubTodo(SubtodoModel subtodo);
  Future<void> addTodo(TodoModel todo);
  Future<void> deleteReminder(int id);
  Future<void> deleteSubTodo(int id);
  Future<void> deleteTodo(int id);
  Future<List<TodoModel>> filterTodosByPriorityAll(int priority);
  Future<List<TodoModel>> filterTodosByPriorityCompleated(int priority);
  Future<List<TodoModel>> filterTodosByPriorityDueDated(int priority);
  Future<List<TodoModel>> getAllCompletedTodos();
  Future<List<TodoModel>> getAllDueDatedTodos();
  Future<List<ReminderModel>> getAllReminders(int todoId);
  Future<List<SubtodoModel>> getAllSubTodos(int todoId);
  Future<List<TodoModel>> getAllTodos();
  Future<SubtodoModel?> getSubTodoById(int id);
  Future<TodoModel?> getTodoById(int id);
  Future<void> updateReminder(ReminderModel reminder);
  Future<void> updateSubTodo(SubtodoModel subTodo);
  Future<void> updateTodo(TodoModel todo);
}

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  final Isar isar;
  TodoLocalDataSourceImpl(this.isar);
  @override
  Future<void> addReminder(ReminderModel reminder) async {
    await isar.writeTxn(() async {
      await isar.reminderModels.put(reminder);
      final todo = await isar.todoModels.get(reminder.todoId);
      if (todo != null) {
        await todo.reminders.load();
        todo.reminders.add(reminder);
        await todo.reminders.save();
      }
    });
  }

  @override
  Future<void> addSubTodo(SubtodoModel subtodo) async {
    await isar.writeTxn(() async {
      // First add the subtodo to the database
      await isar.subtodoModels.put(subtodo);

      // Then link it to the parent todo
      final todo = await isar.todoModels.get(subtodo.todoId);
      if (todo != null) {
        await todo.subtodos.load();
        todo.subtodos.add(subtodo);
        await todo.subtodos.save();
      }
    });
  }

  @override
  Future<void> addTodo(TodoModel todo) async {
    await isar.writeTxn(() async {
      // Save the main todo first
      await todo.subtodos.save();
      await todo.reminders.save();
      await isar.todoModels.put(todo);

      // Save related subtodos and reminders
    });
  }

  @override
  Future<void> deleteReminder(int id) async {
    await isar.writeTxn(() async {
      await isar.reminderModels.delete(id);
    });
  }

  @override
  Future<void> deleteSubTodo(int id) async {
    await isar.writeTxn(() async {
      await isar.subtodoModels.delete(id); // Fixed: delete from subtodoModels, not todoModels
    });
  }

  @override
  Future<void> deleteTodo(int id) async {
    await isar.writeTxn(() async {
      // First, get the todo to access its relationships
      final todo = await isar.todoModels.get(id);
      if (todo != null) {
        await todo.subtodos.load();
        await todo.reminders.load();

        // Delete related subtodos and reminders first
        todo.subtodos.clear();
        todo.reminders.clear();

        // Finally delete the main todo
        await isar.todoModels.delete(id);
      }
    });
  }

  @override
  Future<List<TodoModel>> filterTodosByPriorityAll(int priority) async {
    return await isar.writeTxn(() => isar.todoModels.filter().priorityEqualTo(priority).findAll());
  }

  @override
  Future<List<TodoModel>> getAllCompletedTodos() async {
    return await isar.writeTxn(() => isar.todoModels.filter().isCompletedEqualTo(true).findAll());
  }

  @override
  Future<List<TodoModel>> getAllDueDatedTodos() async {
    final now = DateTime.now();

    // Step 1: Get all todos that have a non-null due date
    final todosWithDueDate = await isar.todoModels.filter().dueDateIsNotNull().findAll();

    // Step 2: Filter those that are due in the future
    final futureTodos = todosWithDueDate
        .where((todo) =>
            todo.dueDate != null && todo.isCompleted == false && todo.dueDate!.isAfter(now))
        .toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    return futureTodos;
  }

  @override
  Future<List<ReminderModel>> getAllReminders(int todoId) async {
    return isar.reminderModels.filter().todo((q) => q.idEqualTo(todoId)).findAll();
  }

  @override
  Future<List<SubtodoModel>> getAllSubTodos(int todoId) async {
    final todo = await isar.todoModels.get(todoId);
    if (todo != null) {
      await todo.subtodos.load();
      return todo.subtodos.toList();
    }
    return [];
  }

  @override
  Future<List<TodoModel>> getAllTodos() async {
    // Load todos with their relationships - this is like doing a JOIN in SQL
    return await isar.todoModels.where().sortByCreatedAtDesc().findAll();
  }

  @override
  Future<SubtodoModel?> getSubTodoById(int id) async {
    final subtodo = await isar.subtodoModels.get(id);
    return subtodo;
  }

  @override
  Future<TodoModel?> getTodoById(int id) async {
    // Load a specific todo with its relationships
    final todo = await isar.todoModels.get(id);
    if (todo != null) {
      // Load the relationships explicitly
      await todo.subtodos.load();
      await todo.reminders.load();
    }
    return todo;
  }

  @override
  Future<void> updateReminder(ReminderModel reminder) async {
    await isar.writeTxn(() async {
      await isar.reminderModels.put(reminder);
    });
  }

  @override
  Future<void> updateSubTodo(SubtodoModel subTodo) async {
    await isar.writeTxn(() async {
      isar.subtodoModels.put(subTodo);
    });
  }

  @override
  Future<void> updateTodo(TodoModel todo) async {
    await isar.writeTxn(() async {
      // Update works the same as put in Isar - it will update if ID exists
      await isar.todoModels.put(todo);

      // Update relationships
      await todo.subtodos.save();
      await todo.reminders.save();
    });
  }

  @override
  Future<List<TodoModel>> filterTodosByPriorityCompleated(int priority) async {
    return await isar.writeTxn(() => isar.todoModels
        .filter()
        .isCompletedEqualTo(true)
        .and()
        .priorityEqualTo(priority)
        .findAll());
  }

  @override
  Future<List<TodoModel>> filterTodosByPriorityDueDated(int priority) async {
    // return futureTodos;
    final now = DateTime.now();
    final todosPriorityDueDated =
        await isar.todoModels.filter().dueDateIsNotNull().and().priorityEqualTo(priority).findAll();
    final List<TodoModel> futureTodosPriority = todosPriorityDueDated
        .where((todo) =>
            todo.dueDate != null && todo.isCompleted == false && todo.dueDate!.isAfter(now))
        .toList()..sort((a,b)=> a.dueDate!.compareTo(b.dueDate!));

    return futureTodosPriority;
  }
}
