import '../models/note_model.dart';

/// Abstract class defining the contract for local data operations on Notes.
abstract class NoteLocalDataSource {
  /// Creates a new note in the local database.
  /// Throws a [DatabaseException] if the operation fails.
  Future<NoteModel> createNote(NoteModel note);

  /// Retrieves all notes from the local database.
  /// Throws a [DatabaseException] if the operation fails.
  Future<List<NoteModel>> getNotes();

  /// Retrieves a single note by its ID from the local database.
  /// Throws a [DatabaseException] if the operation fails or note is not found.
  Future<NoteModel> getNoteById(String id);

  /// Updates an existing note in the local database.
  /// Throws a [DatabaseException] if the operation fails or note is not found.
  Future<NoteModel> updateNote(NoteModel note);

  /// Deletes a note by its ID from the local database.
  /// Throws a [DatabaseException] if the operation fails or note is not found.
  Future<void> deleteNote(String id);

  /// Searches for notes in the local database based on a query string.
  /// Throws a [DatabaseException] if the operation fails.
  Future<List<NoteModel>> searchNotes(String query);
}
