import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart'; // Import Failure for error states
import '../../domain/entities/note_entity.dart';

/// State indicating a note has been successfully created.
class NoteCreatedSuccess extends NotesState {
  final NoteEntity note;

  const NoteCreatedSuccess({required this.note});

  @override
  List<Object> get props => [note];
}

/// State indicating a note has been successfully deleted.
class NoteDeletedSuccess extends NotesState {
  final String noteId;

  const NoteDeletedSuccess({required this.noteId});

  @override
  List<Object> get props => [noteId];
}

/// State indicating an error occurred during a notes operation.
class NotesError extends NotesState {
  final Failure failure;

  const NotesError({required this.failure});

  @override
  List<Object> get props => [failure];
}

/// Initial state of the Notes BLoC.
class NotesInitial extends NotesState {
  const NotesInitial();
}

/// State indicating that notes have been successfully loaded.
class NotesLoaded extends NotesState {
  final List<NoteEntity> notes;

  const NotesLoaded({required this.notes});

  @override
  List<Object> get props => [notes];
}

/// State indicating that notes are currently being loaded or an operation is in progress.
class NotesLoading extends NotesState {
  const NotesLoading();
}

/// State indicating notes have been successfully searched.
/// This can be combined with NotesLoaded if the UI doesn't need to distinguish.
/// For now, we'll keep it separate for clarity if specific search UI is needed.
class NotesSearchLoaded extends NotesState {
  final List<NoteEntity> searchResults;
  final String query;

  const NotesSearchLoaded({required this.searchResults, required this.query});

  @override
  List<Object> get props => [searchResults, query];
}

/// Abstract base class for all Notes states.
/// All specific Notes states should extend this class.
abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object> get props => [];
}

/// State indicating a note has been successfully updated.
class NoteUpdatedSuccess extends NotesState {
  final NoteEntity note;

  const NoteUpdatedSuccess({required this.note});

  @override
  List<Object> get props => [note];
}
