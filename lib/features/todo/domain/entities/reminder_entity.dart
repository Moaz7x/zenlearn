class ReminderEntity {
  final int? id;
  final DateTime reminderTime;
  final String message;
  final int todoId;
  final bool isTriggered;

  ReminderEntity({
    this.id,
    required this.reminderTime,
    required this.message,
    required this.todoId,
    required this.isTriggered,
  });
}