import 'package:isar/isar.dart';
import '../../../../core/errors/exceptions.dart'; // Import custom exceptions
import '../models/note_model.dart';
import 'note_local_data_source.dart';

class NoteLocalDataSourceImpl implements NoteLocalDataSource {
  final Isar isar;

  NoteLocalDataSourceImpl({required this.isar});

  @override
  Future<NoteModel> createNote(NoteModel note) async {
    try {
      await isar.writeTxn(() async {
        await isar.noteModels.put(note); // Insert or update the note
      });
      return note;
    } catch (e) {
      throw DatabaseException();
    }
  }

  @override
  Future<List<NoteModel>> getNotes() async {
    try {
      final notes = await isar.noteModels.where().findAll();
      
      // Sort notes: pinned notes first (sorted by order), then unpinned notes (sorted by order)
      notes.sort((a, b) {
        // First, sort by pinned status (pinned notes come first)
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        
        // If both have the same pinned status, sort by order
        final aOrder = a.order ?? 0;
        final bOrder = b.order ?? 0;
        return aOrder.compareTo(bOrder);
      });
      
      return notes;
    } catch (e) {
      throw DatabaseException();
    }
  }

  @override
  Future<NoteModel> getNoteById(String id) async {
    try {
      final note = await isar.noteModels.filter().idEqualTo(id).findFirst();
      if (note == null) {
        throw NotFoundException(); // Or a more specific exception if needed
      }
      return note;
    } catch (e) {
      if (e is NotFoundException) rethrow; // Re-throw if it's our specific exception
      throw DatabaseException();
    }
  }

  @override
  Future<NoteModel> updateNote(NoteModel note) async {
    try {
      // Check if the note exists before updating
      final existingNote = await isar.noteModels.filter().idEqualTo(note.id).findFirst();
      if (existingNote == null) {
        throw NotFoundException();
      }

      // Isar's put method will update if the unique index 'id' matches
      await isar.writeTxn(() async {
        // We need to ensure the isarId is correct for update,
        // if we are using the NoteModel's 'id' as the unique index.
        // If 'id' is unique, Isar will find and update it.
        // If we are relying on isarId, we need to retrieve the existing one.
        // Given our NoteModel uses `id` with `@Index(unique: true)`, `put` will work.
        note.isarId = existingNote.isarId; // Ensure we update the correct Isar object
        await isar.noteModels.put(note);
      });
      return note;
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException();
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      await isar.writeTxn(() async {
        final success = await isar.noteModels.filter().idEqualTo(id).deleteFirst();
        if (!success) {
          throw NotFoundException(); // Note not found to delete
        }
      });
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException();
    }
  }

  @override
  Future<List<NoteModel>> searchNotes(String query) async {
    try {
      final notes = await isar.noteModels
          .filter()
          .titleContains(query, caseSensitive: false)
          .or()
          .contentContains(query, caseSensitive: false)
          .findAll();
      return notes;
    } catch (e) {
      throw DatabaseException();
    }
  }
}
