import 'package:equatable/equatable.dart';

import '../../domain/entities/note_entity.dart';

/// Event to change the color of a note.
class ChangeNoteColorEvent extends NotesEvent {
  final NoteEntity note;
  final int newColor;

  const ChangeNoteColorEvent({required this.note, required this.newColor});

  @override
  List<Object> get props => [note, newColor];
}

/// Event to create a new note.
class CreateNoteEvent extends NotesEvent {
  final NoteEntity note;

  const CreateNoteEvent({required this.note});

  @override
  List<Object> get props => [note];
}

/// Event to delete a note by its ID.
class DeleteNoteEvent extends NotesEvent {
  final String noteId;

  const DeleteNoteEvent({required this.noteId});

  @override
  List<Object> get props => [noteId];
}

class GetNoteByIdEvent extends NotesEvent {
  final String noteId;

  const GetNoteByIdEvent({required this.noteId});

  @override
  List<Object> get props => [noteId];
}

/// Event to load all notes.
class LoadNotes extends NotesEvent {
  const LoadNotes();
}

/// Abstract base class for all Notes events.
/// All specific Notes events should extend this class.
abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object> get props => [];
}

/// Event to reorder notes.
class ReorderNotesEvent extends NotesEvent {
  final int oldIndex;
  final int newIndex;
  final List<NoteEntity> notes;
  const ReorderNotesEvent({required this.oldIndex, required this.newIndex, required this.notes});

  @override
  List<Object> get props => [oldIndex, newIndex, notes];
}

/// Event to search for notes based on a query.
class SearchNotesEvent extends NotesEvent {
  final String query;

  const SearchNotesEvent({required this.query});

  @override
  List<Object> get props => [query];
}

/// Event to toggle the pinned status of a note.
class TogglePinNoteEvent extends NotesEvent {
  final NoteEntity note;

  const TogglePinNoteEvent({required this.note});

  @override
  List<Object> get props => [note];
}

/// Event to update an existing note.
class UpdateNoteEvent extends NotesEvent {
  final NoteEntity note;

  const UpdateNoteEvent({required this.note});

  @override
  List<Object> get props => [note];
}
