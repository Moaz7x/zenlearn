import 'package:isar/isar.dart';

import '../../domain/entities/todo_entity.dart';
import 'reminder_model.dart';
import 'subtodo_model.dart';

part 'todo_model.g.dart';

@Collection()
class TodoModel {
  Id? id = Isar.autoIncrement;

  @Index()
  late String title;
  late String description;
  late bool isCompleted;
  late DateTime createdAt;
  late int priority;
  DateTime? dueDate;

  final subtodos = IsarLinks<SubtodoModel>();
  final reminders = IsarLinks<ReminderModel>();

  // Convert to domain entity
  TodoEntity toEntity() {
    return TodoEntity(
      id: id,
      title: title,
      description: description,
      isCompleted: isCompleted,
      createdAt: createdAt,
      dueDate: dueDate,
      priority: priority,
      subtodos: subtodos.map((s) => s.toEntity()).toList(),
      reminders: reminders.map((r) => r.toEntity()).toList(),
    );
  }

  // Create from domain entity
  static TodoModel fromEntity(TodoEntity entity) {
    return TodoModel()
      ..id = entity.id
      ..title = entity.title
      ..description = entity.description
      ..isCompleted = entity.isCompleted
      ..createdAt = entity.createdAt
      ..dueDate = entity.dueDate
      ..priority = entity.priority
      ..subtodos.addAll(entity.subtodos.map(SubtodoModel.fromEntity))
      ..reminders.addAll(entity.reminders.map(ReminderModel.fromEntity));
  }
}
