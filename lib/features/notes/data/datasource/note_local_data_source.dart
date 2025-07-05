import '../models/note_model.dart';

/// Abstract class defining the contract for local data operations on Notes.
abstract class NoteLocalDataSource {
  /// Clears all cached data (if caching is implemented).
  Future<void> clearCache();

  /// Creates a new note in the local database.
  /// Throws a [DatabaseException] if the operation fails.
  Future<NoteModel> createNote(NoteModel note);

  /// Creates multiple notes in a single transaction.
  /// Throws a [DatabaseException] if the operation fails.
  Future<List<NoteModel>> createNotesBatch(List<NoteModel> notes);

  /// Deletes a note by its ID from the local database.
  /// Throws a [DatabaseException] if the operation fails or note is not found.
  Future<void> deleteNote(String id);

  /// Deletes multiple notes by their IDs in a single transaction.
  /// Throws a [DatabaseException] if the operation fails.
  Future<void> deleteNotesBatch(List<String> ids);

  /// Retrieves a single note by its ID from the local database.
  /// Throws a [DatabaseException] if the operation fails or note is not found.
  Future<NoteModel> getNoteById(String id);

  // Performance optimization methods

  /// Retrieves all notes from the local database.
  /// Throws a [DatabaseException] if the operation fails.
  Future<List<NoteModel>> getNotes();

  /// Retrieves notes filtered by color.
  /// Throws a [DatabaseException] if the operation fails.
  Future<List<NoteModel>> getNotesByColor(int color);

  /// Retrieves notes filtered by tags.
  /// Throws a [DatabaseException] if the operation fails.
  Future<List<NoteModel>> getNotesByTags(List<String> tags);

  /// Gets the total count of notes in the database.
  /// Throws a [DatabaseException] if the operation fails.
  Future<int> getNotesCount();

  /// Retrieves notes with pagination support.
  /// [offset] - Number of notes to skip
  /// [limit] - Maximum number of notes to return
  /// Throws a [DatabaseException] if the operation fails.
  Future<List<NoteModel>> getNotesPaginated({
    required int offset,
    required int limit,
  });

  /// Retrieves pinned notes only.
  /// Throws a [DatabaseException] if the operation fails.
  Future<List<NoteModel>> getPinnedNotes();

  /// Searches for notes in the local database based on a query string.
  /// Throws a [DatabaseException] if the operation fails.
  Future<List<NoteModel>> searchNotes(String query);

  /// Updates an existing note in the local database.
  /// Throws a [DatabaseException] if the operation fails or note is not found.
  Future<NoteModel> updateNote(NoteModel note);

  /// Updates multiple notes in a single transaction for better performance.
  /// Throws a [DatabaseException] if the operation fails.
  Future<List<NoteModel>> updateNotesBatch(List<NoteModel> notes);
}
