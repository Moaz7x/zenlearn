import 'package:isar/isar.dart';
import '../../domain/entities/note_entity.dart'; // Import the domain entity

// This part directive is crucial for Isar code generation.
// Make sure the filename matches: 'note_model.g.dart' for 'note_model.dart'
part 'note_model.g.dart';

@Collection()
class NoteModel {
  Id isarId = Isar.autoIncrement; // Internal Isar ID

  @Index(unique: true) // Ensure the 'id' from NoteEntity is unique
  late String id; // This will store the NoteEntity's unique string ID

  late String title;
  late String content;
  late DateTime createdAt;
  DateTime? updatedAt;
  bool isPinned;
  int? color; // Stored as an integer (e.g., ARGB value)
  List<String>? tags; // Isar supports List<String> directly
  late int? order; // NEW: Add order field

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.isPinned = false,
    this.color,
    this.tags,
    this.order, // NEW: Add order to constructor
  });

  /// Factory constructor to create a [NoteModel] from a [NoteEntity].
  factory NoteModel.fromEntity(NoteEntity entity) {
    return NoteModel(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isPinned: entity.isPinned,
      color: entity.color,
      tags: entity.tags,
      order: entity.order, // NEW: Assign order from entity
    );
  }

  /// Converts this [NoteModel] to a [NoteEntity].
  NoteEntity toEntity() {
    return NoteEntity(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isPinned: isPinned,
      color: color,
      tags: tags,
      order: order, // NEW: Assign order to entity
    );
  }
}


