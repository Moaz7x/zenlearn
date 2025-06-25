import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs for new notes

import '../../../../core/usecases/usecase.dart'; // For NoParams
import '../../domain/entities/note_entity.dart';
import '../../domain/usecases/create_note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_note_by_id.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/search_notes.dart';
import '../../domain/usecases/update_note.dart';
import 'notes_events.dart';
import 'notes_states.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final CreateNote createNoteUseCase;
  final GetNotes getNotesUseCase;
  final UpdateNote updateNoteUseCase;
  final DeleteNote deleteNoteUseCase;
  final SearchNotes searchNotesUseCase;
final GetNoteById getNoteByIdUseCase; // NEW: Add GetNoteById use case

  NotesBloc({
    required this.createNoteUseCase,
    required this.getNotesUseCase,
     required this.getNoteByIdUseCase, // NEW: Add to constructor
    required this.updateNoteUseCase,
    required this.deleteNoteUseCase,
    required this.searchNotesUseCase,
  }) : super(const NotesInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<CreateNoteEvent>(_onCreateNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
    on<SearchNotesEvent>(_onSearchNotes);
    on<TogglePinNoteEvent>(_onTogglePinNote);
    on<ChangeNoteColorEvent>(_onChangeNoteColor);
    on<GetNoteByIdEvent>(_onGetNoteById); // NEW: Add handler for GetNoteByIdEvent
    on<ReorderNotesEvent>(_onReorderNotes); // NEW: Add handler for ReorderNotesEvent
  
  }

  Future<void> _onGetNoteById(GetNoteByIdEvent event, Emitter<NotesState> emit) async {
    emit(const NotesLoading()); // Or a more specific state like NoteLoadingById
    final result = await getNoteByIdUseCase(GetNoteByIdParams(id: event.noteId));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (note) => emit(NoteLoadedById(note: note)),
    );
  }

  Future<void> _onChangeNoteColor(ChangeNoteColorEvent event, Emitter<NotesState> emit) async {
    // Create a new NoteEntity with the updated color
    final updatedNote = event.note.copyWith(color: event.newColor);
    // Use the update use case
    final result = await updateNoteUseCase(UpdateNoteParams(note: updatedNote));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (note) {
        // If successful, emit a success state and then reload notes to reflect changes
        emit(NoteUpdatedSuccess(note: note));
        add(const LoadNotes());
      },
    );
  }

  Future<void> _onCreateNote(CreateNoteEvent event, Emitter<NotesState> emit) async {
    emit(const NotesLoading()); // Or a more specific state like NoteCreating
    // Ensure the note has a unique ID and creation timestamp if not already set
    final newNote = event.note.copyWith(
      id: event.note.id.isEmpty ? const Uuid().v4() : event.note.id,
      createdAt: event.note.createdAt ,
    );

    final result = await createNoteUseCase(CreateNoteParams(note: newNote));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (note) => emit(NoteCreatedSuccess(note: note)),
    );
    // After creation, you might want to reload all notes to update the list
    add(const LoadNotes());
  }

  Future<void> _onDeleteNote(DeleteNoteEvent event, Emitter<NotesState> emit) async {
    emit(const NotesLoading()); // Or a more specific state like NoteDeleting
    final result = await deleteNoteUseCase(DeleteNoteParams(id: event.noteId));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (_) => emit(NoteDeletedSuccess(noteId: event.noteId)),
    );
    // After deletion, you might want to reload all notes to update the list
    add(const LoadNotes());
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    emit(const NotesLoading());
    final result = await getNotesUseCase(NoParams());
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (notes) => emit(NotesLoaded(notes: notes)),
    );
  }

  Future<void> _onSearchNotes(SearchNotesEvent event, Emitter<NotesState> emit) async {
    emit(const NotesLoading()); // Or a specific state like NotesSearching
    final result = await searchNotesUseCase(SearchNotesParams(query: event.query));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (notes) => emit(NotesSearchLoaded(searchResults: notes, query: event.query)),
    );
  }

  Future<void> _onTogglePinNote(TogglePinNoteEvent event, Emitter<NotesState> emit) async {
    // Create a new NoteEntity with the toggled pinned status
    final updatedNote = event.note.copyWith(isPinned: !event.note.isPinned);
    // Use the update use case
    final result = await updateNoteUseCase(UpdateNoteParams(note: updatedNote));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (note) {
        // If successful, emit a success state and then reload notes to reflect changes
        emit(NoteUpdatedSuccess(note: note));
        add(const LoadNotes());
      },
    );
  }

  Future<void> _onUpdateNote(UpdateNoteEvent event, Emitter<NotesState> emit) async {
    emit(const NotesLoading()); // Or a more specific state like NoteUpdating
    final updatedNote = event.note.copyWith(updatedAt: DateTime.now());
    final result = await updateNoteUseCase(UpdateNoteParams(note: updatedNote));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (note) => emit(NoteUpdatedSuccess(note: note)),
    );
    // After update, you might want to reload all notes to update the list
    add(const LoadNotes());
  }
}

  Future<void> _onReorderNotes(ReorderNotesEvent event, Emitter<NotesState> emit) async {
    
      final notes = List<NoteEntity>.from(event.notes);
      
      // Separate pinned and unpinned notes
      final pinnedNotes = notes.where((note) => note.isPinned).toList();
      final unpinnedNotes = notes.where((note) => !note.isPinned).toList();
      
      // Determine which list to reorder
      if (event.oldIndex < pinnedNotes.length && event.newIndex < pinnedNotes.length) {
        // Reordering within pinned notes
        final note = pinnedNotes.removeAt(event.oldIndex);
        pinnedNotes.insert(event.newIndex, note);
      } else if (event.oldIndex >= pinnedNotes.length && event.newIndex >= pinnedNotes.length) {
        // Reordering within unpinned notes
        final adjustedOldIndex = event.oldIndex - pinnedNotes.length;
        final adjustedNewIndex = event.newIndex - pinnedNotes.length;
        final note = unpinnedNotes.removeAt(adjustedOldIndex);
        unpinnedNotes.insert(adjustedNewIndex, note);
      }
      
      // Combine the lists back together
      final reorderedNotes = [...pinnedNotes, ...unpinnedNotes];
      emit(NotesLoaded(notes: reorderedNotes));
    
  }

