import 'package:equatable/equatable.dart';

import '../../domain/entities/note_entity.dart';

class AddTagToNoteEvent extends NotesEvent {
  final NoteEntity note;
  final String tag;

  const AddTagToNoteEvent({required this.note, required this.tag});

  @override
  List<Object> get props => [note, tag];
}

/// Event to change the color of a note.
class ChangeNoteColorEvent extends NotesEvent {
  final NoteEntity note;
  final int newColor;

  const ChangeNoteColorEvent({required this.note, required this.newColor});

  @override
  List<Object> get props => [note, newColor];
}

class ClearColorFilterEvent extends NotesEvent {
  const ClearColorFilterEvent();

  @override
  List<Object> get props => [];
}

class ClearSortEvent extends NotesEvent {
  const ClearSortEvent();

  @override
  List<Object> get props => [];
}

class ClearTagFilterEvent extends NotesEvent {
  const ClearTagFilterEvent();

  @override
  List<Object> get props => [];
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

class FilterNotesByColorEvent extends NotesEvent {
  final int? color;

  const FilterNotesByColorEvent({this.color});

  @override
  List<Object?> get props => [color];
}

class FilterNotesByTagEvent extends NotesEvent {
  final String tag;

  const FilterNotesByTagEvent({required this.tag});

  @override
  List<Object> get props => [tag];
}

class GetNoteByIdEvent extends NotesEvent {
  final String noteId;

  const GetNoteByIdEvent({required this.noteId});

  @override
  List<Object> get props => [noteId];
}

/// Event to load all notes.
class LoadNotes extends NotesEvent {
  final String? sortBy;
  final bool? sortAscending;
  final int? filterColor;
  final String? filterTag;

  const LoadNotes({
    this.sortBy,
    this.sortAscending,
    this.filterColor,
    this.filterTag,
  });

  @override
  List<Object?> get props => [
        sortBy,
        sortAscending,
        filterColor,
        filterTag,
      ];
}

/// Abstract base class for all Notes events.
/// All specific Notes events should extend this class.
abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

class RemoveTagFromNoteEvent extends NotesEvent {
  final NoteEntity note;
  final String tag;

  const RemoveTagFromNoteEvent({required this.note, required this.tag});

  @override
  List<Object> get props => [note, tag];
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

/// Event to reorder pinned notes specifically
class ReorderPinnedNotesEvent extends NotesEvent {
  final int oldIndex;
  final int newIndex;
  final List<NoteEntity> pinnedNotes;

  const ReorderPinnedNotesEvent({
    required this.oldIndex,
    required this.newIndex,
    required this.pinnedNotes,
  });

  @override
  List<Object> get props => [oldIndex, newIndex, pinnedNotes];
}

/// Event to reorder unpinned notes specifically
class ReorderUnpinnedNotesEvent extends NotesEvent {
  final int oldIndex;
  final int newIndex;
  final List<NoteEntity> unpinnedNotes;

  const ReorderUnpinnedNotesEvent({
    required this.oldIndex,
    required this.newIndex,
    required this.unpinnedNotes,
  });

  @override
  List<Object> get props => [oldIndex, newIndex, unpinnedNotes];
}

/// Event to search for notes based on a query.
class SearchNotesEvent extends NotesEvent {
  final String query;

  const SearchNotesEvent({required this.query});

  @override
  List<Object> get props => [query];
}

class SortNotesEvent extends NotesEvent {
  final String? sortBy;
  final bool ascending;

  const SortNotesEvent({this.sortBy, this.ascending = true});

  @override
  List<Object?> get props => [sortBy, ascending];
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


