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

  String? _currentSortBy; // To keep track of current sorting
  bool? _currentSortAscending; // To keep track of current sorting direction
  int? _currentFilterColor; // To keep track of current color filter
  String? _currentFilterTag; // To keep track of current tag filter

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
    on<AddTagToNoteEvent>(_onAddTagToNote);
    on<RemoveTagFromNoteEvent>(_onRemoveTagFromNote);
    on<SortNotesEvent>(_onSortNotes);
    on<FilterNotesByColorEvent>(_onFilterNotesByColor);
    on<FilterNotesByTagEvent>(_onFilterNotesByTag);
    on<ClearTagFilterEvent>(_onClearTagFilter);
    on<ClearColorFilterEvent>(_onClearColorFilter);
    on<ReorderPinnedNotesEvent>(_onReorderPinnedNotes);
    on<ReorderUnpinnedNotesEvent>(_onReorderUnpinnedNotes);
  }

  Future<void> _onAddTagToNote(AddTagToNoteEvent event, Emitter<NotesState> emit) async {
    final currentTags = event.note.tags?.toList() ?? [];
    if (!currentTags.contains(event.tag)) {
      currentTags.add(event.tag);
      final updatedNote = event.note.copyWith(tags: currentTags);
      final result = await updateNoteUseCase(UpdateNoteParams(note: updatedNote));
      result.fold(
        (failure) => emit(NotesError(failure: failure)),
        (note) {
          emit(NoteUpdatedSuccess(note: note));
          add(LoadNotes(
            sortBy: _currentSortBy,
            sortAscending: _currentSortAscending,
            filterColor: _currentFilterColor,
            filterTag: _currentFilterTag,
          ));
        },
      );
    }
  }

  Future<void> _onChangeNoteColor(ChangeNoteColorEvent event, Emitter<NotesState> emit) async {
    final updatedNote = event.note.copyWith(color: event.newColor);
    final result = await updateNoteUseCase(UpdateNoteParams(note: updatedNote));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (note) {
        emit(NoteUpdatedSuccess(note: note));
        add(LoadNotes(
          sortBy: _currentSortBy,
          sortAscending: _currentSortAscending,
          filterColor: _currentFilterColor,
          filterTag: _currentFilterTag,
        ));
      },
    );
  }

  Future<void> _onClearColorFilter(ClearColorFilterEvent event, Emitter<NotesState> emit) async {
    _currentFilterColor = null;
    add(LoadNotes(
      sortBy: _currentSortBy,
      sortAscending: _currentSortAscending,
      filterColor: _currentFilterColor,
      filterTag: _currentFilterTag,
    ));
  }

  Future<void> _onClearTagFilter(ClearTagFilterEvent event, Emitter<NotesState> emit) async {
    _currentFilterTag = null;
    add(LoadNotes(
      sortBy: _currentSortBy,
      sortAscending: _currentSortAscending,
      filterColor: _currentFilterColor,
      filterTag: _currentFilterTag,
    ));
  }

  Future<void> _onCreateNote(CreateNoteEvent event, Emitter<NotesState> emit) async {
    emit(const NotesLoading());
    final newNote = event.note.copyWith(
      id: event.note.id.isEmpty ? const Uuid().v4() : event.note.id,
      createdAt: event.note.createdAt,
    );

    final result = await createNoteUseCase(CreateNoteParams(note: newNote));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (note) => emit(NoteCreatedSuccess(note: note)),
    );
    add(LoadNotes(
      sortBy: _currentSortBy,
      sortAscending: _currentSortAscending,
      filterColor: _currentFilterColor,
      filterTag: _currentFilterTag,
    ));
  }

  Future<void> _onDeleteNote(DeleteNoteEvent event, Emitter<NotesState> emit) async {
    emit(const NotesLoading());
    final result = await deleteNoteUseCase(DeleteNoteParams(id: event.noteId));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (_) => emit(NoteDeletedSuccess(noteId: event.noteId)),
    );
    add(LoadNotes(
      sortBy: _currentSortBy,
      sortAscending: _currentSortAscending,
      filterColor: _currentFilterColor,
      filterTag: _currentFilterTag,
    ));
  }

  Future<void> _onFilterNotesByColor(FilterNotesByColorEvent event, Emitter<NotesState> emit) async {
    _currentFilterColor = event.color;
    add(LoadNotes(
      sortBy: _currentSortBy,
      sortAscending: _currentSortAscending,
      filterColor: _currentFilterColor,
      filterTag: _currentFilterTag,
    ));
  }

  Future<void> _onFilterNotesByTag(FilterNotesByTagEvent event, Emitter<NotesState> emit) async {
    _currentFilterTag = event.tag;
    add(LoadNotes(
      sortBy: _currentSortBy,
      sortAscending: _currentSortAscending,
      filterColor: _currentFilterColor,
      filterTag: _currentFilterTag,
    ));
  }

  Future<void> _onGetNoteById(GetNoteByIdEvent event, Emitter<NotesState> emit) async {
    emit(const NotesLoading());
    final result = await getNoteByIdUseCase(GetNoteByIdParams(id: event.noteId));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (note) => emit(NoteLoadedById(note: note)),
    );
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    emit(const NotesLoading());

    _currentSortBy = event.sortBy ?? _currentSortBy;
    _currentSortAscending = event.sortAscending ?? _currentSortAscending;
    _currentFilterColor = event.filterColor; // Directly assign, don't use ??
    _currentFilterTag = event.filterTag; // Directly assign to allow clearing filter

    final result = await getNotesUseCase(NoParams());
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (notes) {
        List<NoteEntity> filteredNotes = List.from(notes);

        // Apply color filter
        if (_currentFilterColor != null) {
          filteredNotes = filteredNotes
              .where((note) => note.color == _currentFilterColor)
              .toList();
        }

        // Apply tag filter
        if (_currentFilterTag != null && _currentFilterTag!.isNotEmpty) {
          filteredNotes = filteredNotes
              .where((note) => note.tags?.contains(_currentFilterTag) ?? false)
              .toList();
        }

        // Apply sorting
        if (_currentSortBy != null) {
          filteredNotes.sort((a, b) {
            int compareResult = 0;
            switch (_currentSortBy) {
              case 'date':
                compareResult = a.createdAt.compareTo(b.createdAt);
                break;
              case 'title':
                compareResult = a.title.compareTo(b.title);
                break;
              case 'pinned':
                compareResult = a.isPinned == b.isPinned
                    ? 0
                    : (a.isPinned ? -1 : 1);
                break;
            }
            return _currentSortAscending == true
                ? compareResult
                : -compareResult;
          });
        }

        emit(NotesLoaded(
          notes: filteredNotes,
          currentSortBy: _currentSortBy,
          currentSortAscending: _currentSortAscending,
          currentFilterColor: _currentFilterColor,
          currentFilterTag: _currentFilterTag,
        ));
      },
    );
  }

  Future<void> _onRemoveTagFromNote(RemoveTagFromNoteEvent event, Emitter<NotesState> emit) async {
    final currentTags = event.note.tags?.toList() ?? [];
    if (currentTags.contains(event.tag)) {
      currentTags.remove(event.tag);
      final updatedNote = event.note.copyWith(tags: currentTags);
      final result = await updateNoteUseCase(UpdateNoteParams(note: updatedNote));
      result.fold(
        (failure) => emit(NotesError(failure: failure)),
        (note) {
          emit(NoteUpdatedSuccess(note: note));
          add(LoadNotes(
            sortBy: _currentSortBy,
            sortAscending: _currentSortAscending,
            filterColor: _currentFilterColor,
            filterTag: _currentFilterTag,
          ));
        },
      );
    }
  }

  Future<void> _onReorderNotes(ReorderNotesEvent event, Emitter<NotesState> emit) async {
    final notes = List<NoteEntity>.from(event.notes);

    final pinnedNotes = notes.where((note) => note.isPinned).toList();
    final unpinnedNotes = notes.where((note) => !note.isPinned).toList();

    if (event.oldIndex < pinnedNotes.length && event.newIndex < pinnedNotes.length) {
      final note = pinnedNotes.removeAt(event.oldIndex);
      pinnedNotes.insert(event.newIndex, note);
    } else if (event.oldIndex >= pinnedNotes.length && event.newIndex >= pinnedNotes.length) {
      final adjustedOldIndex = event.oldIndex - pinnedNotes.length;
      final adjustedNewIndex = event.newIndex - pinnedNotes.length;
      final note = unpinnedNotes.removeAt(adjustedOldIndex);
      unpinnedNotes.insert(adjustedNewIndex, note);
    }

    final reorderedNotes = [...pinnedNotes, ...unpinnedNotes];

    final List<Future<void>> updateFutures = [];

    for (int i = 0; i < reorderedNotes.length; i++) {
      final noteToUpdate = reorderedNotes[i].copyWith(order: i);
      updateFutures.add(updateNoteUseCase(UpdateNoteParams(note: noteToUpdate)).then((result) {
        result.fold(
          (failure) {
            print('Error updating note order for ${noteToUpdate.id}: ${failure.message}');
          },
          (_) {},
        );
      }));
    }

    await Future.wait(updateFutures);

    emit(NotesLoaded(
      notes: reorderedNotes,
      currentSortBy: _currentSortBy,
      currentSortAscending: _currentSortAscending,
      currentFilterColor: _currentFilterColor,
      currentFilterTag: _currentFilterTag,
    ));
  }

  /// Handles reordering of pinned notes
  Future<void> _onReorderPinnedNotes(ReorderPinnedNotesEvent event, Emitter<NotesState> emit) async {
    try {
      // Don't emit loading state for better UX (optimistic updates already shown)

      // Update the order field for each pinned note based on new positions
      final List<Future<void>> updateFutures = [];

      for (int i = 0; i < event.pinnedNotes.length; i++) {
        final note = event.pinnedNotes[i];
        final updatedNote = note.copyWith(
          order: i, // Set order based on position in list
          updatedAt: DateTime.now(),
        );

        // Add to batch update
        updateFutures.add(
          updateNoteUseCase(UpdateNoteParams(note: updatedNote)).then((result) {
            result.fold(
              (failure) {
                // Log error but don't stop other updates
                print('Error updating pinned note order for ${note.id}: ${failure.toString()}');
              },
              (_) {}, // Success - continue
            );
          })
        );
      }

      // Wait for all updates to complete
      await Future.wait(updateFutures);

      // Reload notes to reflect the new order
      add(LoadNotes(
        sortBy: _currentSortBy,
        sortAscending: _currentSortAscending,
        filterColor: _currentFilterColor,
        filterTag: _currentFilterTag,
      ));

    } catch (e) {
      emit(NotesError(failure: Exception('Failed to reorder pinned notes: $e') as dynamic));
    }
  }

  /// Handles reordering of unpinned notes
  Future<void> _onReorderUnpinnedNotes(ReorderUnpinnedNotesEvent event, Emitter<NotesState> emit) async {
    try {
      // Don't emit loading state for better UX (optimistic updates already shown)

      // Update the order field for each unpinned note based on new positions
      final List<Future<void>> updateFutures = [];

      for (int i = 0; i < event.unpinnedNotes.length; i++) {
        final note = event.unpinnedNotes[i];
        final updatedNote = note.copyWith(
          order: i, // Set order based on position in list
          updatedAt: DateTime.now(),
        );

        // Add to batch update
        updateFutures.add(
          updateNoteUseCase(UpdateNoteParams(note: updatedNote)).then((result) {
            result.fold(
              (failure) {
                // Log error but don't stop other updates
                print('Error updating unpinned note order for ${note.id}: ${failure.toString()}');
              },
              (_) {}, // Success - continue
            );
          })
        );
      }

      // Wait for all updates to complete
      await Future.wait(updateFutures);

      // Reload notes to reflect the new order
      add(LoadNotes(
        sortBy: _currentSortBy,
        sortAscending: _currentSortAscending,
        filterColor: _currentFilterColor,
        filterTag: _currentFilterTag,
      ));

    } catch (e) {
      emit(NotesError(failure: Exception('Failed to reorder unpinned notes: $e') as dynamic));
    }
  }

  Future<void> _onSearchNotes(SearchNotesEvent event, Emitter<NotesState> emit) async {
    emit(const NotesLoading());
    final result = await searchNotesUseCase(SearchNotesParams(query: event.query));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (notes) => emit(NotesSearchLoaded(searchResults: notes, query: event.query)),
    );
  }

  Future<void> _onSortNotes(SortNotesEvent event, Emitter<NotesState> emit) async {
    _currentSortBy = event.sortBy;
    _currentSortAscending = event.ascending;
    add(LoadNotes(
      sortBy: _currentSortBy,
      sortAscending: _currentSortAscending,
      filterColor: _currentFilterColor,
      filterTag: _currentFilterTag,
    ));
  }

  Future<void> _onTogglePinNote(TogglePinNoteEvent event, Emitter<NotesState> emit) async {
    final updatedNote = event.note.copyWith(isPinned: !event.note.isPinned);
    final result = await updateNoteUseCase(UpdateNoteParams(note: updatedNote));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (note) {
        emit(NoteUpdatedSuccess(note: note));
        add(LoadNotes(
          sortBy: _currentSortBy,
          sortAscending: _currentSortAscending,
          filterColor: _currentFilterColor,
          filterTag: _currentFilterTag,
        ));
      },
    );
  }

  Future<void> _onUpdateNote(UpdateNoteEvent event, Emitter<NotesState> emit) async {
    emit(const NotesLoading());
    final updatedNote = event.note.copyWith(updatedAt: DateTime.now());
    final result = await updateNoteUseCase(UpdateNoteParams(note: updatedNote));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (note) => emit(NoteUpdatedSuccess(note: note)),
    );
    add(LoadNotes(
      sortBy: _currentSortBy,
      sortAscending: _currentSortAscending,
      filterColor: _currentFilterColor,
      filterTag: _currentFilterTag,
    ));
  }
}


