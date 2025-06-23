import 'reminder_entity.dart';
import 'subtodo_entity.dart';

class TodoEntity {
  final int? id;
  late final String title;
  late final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? dueDate;
  final int priority;
  final List<SubtodoEntity> subtodos;
  final List<ReminderEntity> reminders;

  TodoEntity({
    this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.isCompleted,
    required this.createdAt,
    this.dueDate,
    required this.subtodos,
    required this.reminders,
  });

  TodoEntity copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
    int? priority,
    List<SubtodoEntity>? subtodos,
    List<ReminderEntity>? reminders,
  }) {
    return TodoEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      subtodos: subtodos ?? this.subtodos,
      reminders: reminders ?? this.reminders,
    );
  }
}
