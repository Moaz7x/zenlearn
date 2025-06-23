import 'package:isar/isar.dart';

import '../../domain/entities/reminder_entity.dart';
import 'todo_model.dart';

part 'reminder_model.g.dart';

@Collection()
class ReminderModel {
  Id? id = Isar.autoIncrement;

  late DateTime reminderTime;
  late String message;
  late int todoId; // Foreign key reference

  @Backlink(to: 'reminders')
  final todo = IsarLinks<TodoModel>();
  late bool isTriggered;

  // Convert to domain entity
  ReminderEntity toEntity() {
    return ReminderEntity(
      id: id,
      reminderTime: reminderTime,
      message: message,
      todoId: todoId,
      isTriggered: isTriggered,
    );
  }

  // Create from domain entity
  static ReminderModel fromEntity(ReminderEntity entity) {
    return ReminderModel()
      ..id = entity.id
      ..reminderTime = entity.reminderTime
      ..message = entity.message
      ..todoId = entity.todoId
      ..isTriggered = entity.isTriggered;
  }
}
