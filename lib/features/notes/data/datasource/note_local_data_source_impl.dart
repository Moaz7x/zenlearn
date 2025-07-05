import 'package:isar/isar.dart';

import '../../../../core/errors/exceptions.dart'; // Import custom exceptions
import '../models/note_model.dart';
import 'note_local_data_source.dart';

class NoteLocalDataSourceImpl implements NoteLocalDataSource {
  final Isar isar;

  NoteLocalDataSourceImpl({required this.isar});

  @override
  Future<void> clearCache() async {
    // For Isar, we don't need to implement caching as it's handled internally
    // This method is here for future extensibility if we add a caching layer
    return;
  }

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
  Future<List<NoteModel>> createNotesBatch(List<NoteModel> notes) async {
    try {
      await isar.writeTxn(() async {
        await isar.noteModels.putAll(notes);
      });
      return notes;
    } catch (e) {
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
  Future<void> deleteNotesBatch(List<String> ids) async {
    try {
      await isar.writeTxn(() async {
        for (final id in ids) {
          await isar.noteModels.filter().idEqualTo(id).deleteFirst();
        }
      });
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
  Future<List<NoteModel>> getNotes() async {
    try {
      final notes = await isar.noteModels.where().findAll();

      // Sort notes: pinned notes first (sorted by order), then unpinned notes (sorted by order)
      notes.sort((a, b) {
        // Sort by order first, then by pinned status
        final aOrder = a.order ?? 0;
        final bOrder = b.order ?? 0;
        if (aOrder != bOrder) {
          return aOrder.compareTo(bOrder);
        }
        // If order is the same, sort by pinned status (pinned notes come first)
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return 0;
      });

      return notes;
    } catch (e) {
      throw DatabaseException();
    }
  }

  @override
  Future<List<NoteModel>> getNotesByColor(int color) async {
    try {
      final notes = await isar.noteModels
          .filter()
          .colorEqualTo(color)
          .findAll();
      return notes;
    } catch (e) {
      throw DatabaseException();
    }
  }

  @override
  Future<List<NoteModel>> getNotesByTags(List<String> tags) async {
    try {
      final notes = await isar.noteModels
          .filter()
          .anyOf(tags, (q, tag) => q.tagsElementContains(tag))
          .findAll();
      return notes;
    } catch (e) {
      throw DatabaseException();
    }
  }

  @override
  Future<int> getNotesCount() async {
    try {
      return await isar.noteModels.count();
    } catch (e) {
      throw DatabaseException();
    }
  }

  @override
  Future<List<NoteModel>> getNotesPaginated({
    required int offset,
    required int limit,
  }) async {
    try {
      final notes = await isar.noteModels
          .where()
          .offset(offset)
          .limit(limit)
          .findAll();

      // Apply the same sorting logic as getNotes()
      notes.sort((a, b) {
        final aOrder = a.order ?? 0;
        final bOrder = b.order ?? 0;
        if (aOrder != bOrder) {
          return aOrder.compareTo(bOrder);
        }
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return 0;
      });

      return notes;
    } catch (e) {
      throw DatabaseException();
    }
  }

  @override
  Future<List<NoteModel>> getPinnedNotes() async {
    try {
      final notes = await isar.noteModels
          .filter()
          .isPinnedEqualTo(true)
          .findAll();
      return notes;
    } catch (e) {
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

  // Performance optimization methods implementation

  @override
  Future<List<NoteModel>> updateNotesBatch(List<NoteModel> notes) async {
    try {
      await isar.writeTxn(() async {
        await isar.noteModels.putAll(notes);
      });
      return notes;
    } catch (e) {
      throw DatabaseException();
    }
  }
}
