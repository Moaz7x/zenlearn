import 'package:isar/isar.dart';
import '../../domain/entities/note_entity.dart'; // Import the domain entity

// This part directive is crucial for Isar code generation.
// Make sure the filename matches: 'note_model.g.dart' for 'note_model.dart'
part 'note_model.g.dart';

@Collection()
class NoteModel {
  // Isar uses 'Id' for the primary key.
  // You can use 'Id id = Isar.autoIncrement;' for auto-incrementing IDs.
  // Or, if you want to use a custom String ID from NoteEntity, you'd map it.
  // For simplicity and to match NoteEntity's String ID, we'll use a hash for Isar's int Id.
  // Or, if NoteEntity's ID is truly unique and can be converted to int, use that.
  // Let's assume NoteEntity's ID is a UUID string, so we'll use Isar.autoIncrement for Isar's internal ID
  // and store the NoteEntity's ID as a separate field.
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

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.isPinned = false,
    this.color,
    this.tags,
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
    );
  }
}
