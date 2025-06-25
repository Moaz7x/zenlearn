import 'package:equatable/equatable.dart';

/// Represents a Note entity in the domain layer.
/// This entity is pure and does not depend on any framework or database specifics.
class NoteEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPinned;
  final int? color; // Represents a color value, e.g., ARGB integer
  final List<String>? tags;

  const NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.isPinned = false,
    this.color,
    this.tags,
  });

  /// Creates a copy of this NoteEntity with the given fields replaced with the new values.
  NoteEntity copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    int? color,
    List<String>? tags,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      color: color ?? this.color,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        createdAt,
        updatedAt,
        isPinned,
        color,
        tags,
      ];
}
