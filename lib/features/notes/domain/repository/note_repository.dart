import 'package:dartz/dartz.dart'; // For Either
import '../../../../core/errors/failures.dart'; // Import the Failure definitions
import '../entities/note_entity.dart'; // Import the NoteEntity

/// Abstract class defining the contract for Note operations in the domain layer.
/// This interface specifies what operations can be performed on Note entities,
/// without specifying how these operations are implemented (e.g., from a database or API).
abstract class NoteRepository {
  /// Creates a new note.
  /// Returns [Right] with [NoteEntity] if successful, or [Left] with [Failure] on error.
  Future<Either<Failure, NoteEntity>> createNote(NoteEntity note);

  /// Retrieves a list of all notes.
  /// Returns [Right] with a [List<NoteEntity>] if successful, or [Left] with [Failure] on error.
  Future<Either<Failure, List<NoteEntity>>> getNotes();

  /// Retrieves a single note by its ID.
  /// Returns [Right] with [NoteEntity] if found, or [Left] with [Failure] (e.g., NotFoundFailure) on error.
  Future<Either<Failure, NoteEntity>> getNoteById(String id);

  /// Updates an existing note.
  /// Returns [Right] with [NoteEntity] (the updated note) if successful, or [Left] with [Failure] on error.
  Future<Either<Failure, NoteEntity>> updateNote(NoteEntity note);

  /// Deletes a note by its ID.
  /// Returns [Right] with [void] (indicating success) if successful, or [Left] with [Failure] on error.
  Future<Either<Failure, void>> deleteNote(String id);

  /// Searches for notes based on a query string.
  /// Returns [Right] with a [List<NoteEntity>] if successful, or [Left] with [Failure] on error.
  Future<Either<Failure, List<NoteEntity>>> searchNotes(String query);
}
