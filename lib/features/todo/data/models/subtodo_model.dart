import 'package:isar/isar.dart';

import '../../domain/entities/subtodo_entity.dart';
import 'todo_model.dart';

part 'subtodo_model.g.dart';

@Collection()
class SubtodoModel {
  Id? id = Isar.autoIncrement;

  late String title;
  late bool isCompleted;
  late int todoId; // Foreign key reference

  @Backlink(to: 'subtodos')
  final todo = IsarLinks<TodoModel>();

  // Convert to domain entity - this method bridges data layer to domain layer
  SubtodoEntity toEntity() {
    return SubtodoEntity(
      id: id,
      title: title,
      isCompleted: isCompleted,
      todoId: todoId,
    );
  }

  // Create from domain entity - this allows us to save domain objects
  static SubtodoModel fromEntity(SubtodoEntity entity) {
    return SubtodoModel()
      ..id = entity.id
      ..title = entity.title
      ..isCompleted = entity.isCompleted
      ..todoId = entity.todoId;
  }
}
