import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/usecases/create_note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_note_by_id.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/search_notes.dart';
import '../../domain/usecases/update_note.dart';
import 'notes_events.dart';
import 'notes_states.dart';

/// Optimized BLoC with debouncing, caching, and efficient state updates
class OptimizedNotesBloc extends Bloc<NotesEvent, NotesState> {
  static const Duration _debounceDuration = Duration(milliseconds: 300);
  final CreateNote createNoteUseCase;
  final GetNotes getNotesUseCase;
  final UpdateNote updateNoteUseCase;
  final DeleteNote deleteNoteUseCase;
  final SearchNotes searchNotesUseCase;

  final GetNoteById getNoteByIdUseCase;
  // State management
  String? _currentSortBy;
  bool? _currentSortAscending;
  int? _currentFilterColor;
  String? _currentFilterTag;
  List<NoteEntity> _cachedNotes = [];

  bool _isInitialized = false;
  // Debouncing
  Timer? _searchDebounceTimer;
  Timer? _filterDebounceTimer;

  // Stream controllers for reactive updates
  final _notesStreamController = BehaviorSubject<List<NoteEntity>>();
  final _loadingStreamController = BehaviorSubject<bool>.seeded(false);

  OptimizedNotesBloc({
    required this.createNoteUseCase,
    required this.getNotesUseCase,
    required this.updateNoteUseCase,
    required this.deleteNoteUseCase,
    required this.searchNotesUseCase,
    required this.getNoteByIdUseCase,
  }) : super(const NotesInitial()) {
    // Event handlers
    on<LoadNotes>(_onLoadNotes);
    on<CreateNoteEvent>(_onCreateNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
    on<SearchNotesEvent>(_onSearchNotes, transformer: _debounceTransformer());
    on<TogglePinNoteEvent>(_onTogglePinNote);
    on<ChangeNoteColorEvent>(_onChangeNoteColor);
    on<GetNoteByIdEvent>(_onGetNoteById);
    on<ReorderNotesEvent>(_onReorderNotes);
    on<AddTagToNoteEvent>(_onAddTagToNote);
    on<RemoveTagFromNoteEvent>(_onRemoveTagFromNote);
    on<SortNotesEvent>(_onSortNotes, transformer: _debounceTransformer());
    on<FilterNotesByColorEvent>(_onFilterNotesByColor, transformer: _debounceTransformer());
    on<FilterNotesByTagEvent>(_onFilterNotesByTag, transformer: _debounceTransformer());
    on<ClearTagFilterEvent>(_onClearTagFilter);
    on<ClearColorFilterEvent>(_onClearColorFilter);
  }

  @override
  Future<void> close() {
    _searchDebounceTimer?.cancel();
    _filterDebounceTimer?.cancel();
    _notesStreamController.close();
    _loadingStreamController.close();
    return super.close();
  }

  List<NoteEntity> _applyFiltersAndSorting(List<NoteEntity> notes) {
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

    return filteredNotes;
  }

  // Debounce transformer for search and filter events
  EventTransformer<T> _debounceTransformer<T>() {
    return (events, mapper) => events
        .debounceTime(_debounceDuration)
        .asyncExpand(mapper);
  }

  Future<void> _onAddTagToNote(AddTagToNoteEvent event, Emitter<NotesState> emit) async {
    final currentTags = event.note.tags?.toList() ?? [];
    if (!currentTags.contains(event.tag)) {
      currentTags.add(event.tag);
      final updatedNote = event.note.copyWith(
        tags: currentTags,
        updatedAt: DateTime.now(),
      );

      final result = await updateNoteUseCase(UpdateNoteParams(note: updatedNote));
      result.fold(
        (failure) => emit(NotesError(failure: failure)),
        (note) {
          final index = _cachedNotes.indexWhere((n) => n.id == note.id);
          if (index != -1) {
            _cachedNotes[index] = note;
            final filteredNotes = _applyFiltersAndSorting(_cachedNotes);

            emit(NoteUpdatedSuccess(note: note));
            emit(NotesLoaded(
              notes: filteredNotes,
              currentSortBy: _currentSortBy,
              currentSortAscending: _currentSortAscending,
              currentFilterColor: _currentFilterColor,
              currentFilterTag: _currentFilterTag,
            ));
          }
        },
      );
    }
  }

  Future<void> _onChangeNoteColor(ChangeNoteColorEvent event, Emitter<NotesState> emit) async {
    final updatedNote = event.note.copyWith(
      color: event.newColor,
      updatedAt: DateTime.now(),
    );

    final result = await updateNoteUseCase(UpdateNoteParams(note: updatedNote));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (note) {
        final index = _cachedNotes.indexWhere((n) => n.id == note.id);
        if (index != -1) {
          _cachedNotes[index] = note;
          final filteredNotes = _applyFiltersAndSorting(_cachedNotes);

          emit(NoteUpdatedSuccess(note: note));
          emit(NotesLoaded(
            notes: filteredNotes,
            currentSortBy: _currentSortBy,
            currentSortAscending: _currentSortAscending,
            currentFilterColor: _currentFilterColor,
            currentFilterTag: _currentFilterTag,
          ));
        }
      },
    );
  }

  Future<void> _onClearColorFilter(ClearColorFilterEvent event, Emitter<NotesState> emit) async {
    _currentFilterColor = null;

    final filteredNotes = _applyFiltersAndSorting(_cachedNotes);
    emit(NotesLoaded(
      notes: filteredNotes,
      currentSortBy: _currentSortBy,
      currentSortAscending: _currentSortAscending,
      currentFilterColor: _currentFilterColor,
      currentFilterTag: _currentFilterTag,
    ));
  }

  Future<void> _onClearTagFilter(ClearTagFilterEvent event, Emitter<NotesState> emit) async {
    _currentFilterTag = null;

    final filteredNotes = _applyFiltersAndSorting(_cachedNotes);
    emit(NotesLoaded(
      notes: filteredNotes,
      currentSortBy: _currentSortBy,
      currentSortAscending: _currentSortAscending,
      currentFilterColor: _currentFilterColor,
      currentFilterTag: _currentFilterTag,
    ));
  }

  Future<void> _onCreateNote(CreateNoteEvent event, Emitter<NotesState> emit) async {
    final result = await createNoteUseCase(CreateNoteParams(note: event.note));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (note) {
        // Optimized: Add to cache instead of full reload
        _cachedNotes.add(note);
        final filteredNotes = _applyFiltersAndSorting(_cachedNotes);
        
        emit(NoteCreatedSuccess(note: note));
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

  Future<void> _onDeleteNote(DeleteNoteEvent event, Emitter<NotesState> emit) async {
    final result = await deleteNoteUseCase(DeleteNoteParams(id: event.noteId));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (_) {
        // Optimized: Remove from cache instead of full reload
        _cachedNotes.removeWhere((note) => note.id == event.noteId);
        final filteredNotes = _applyFiltersAndSorting(_cachedNotes);
        
        emit(NoteDeletedSuccess(noteId: event.noteId));
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

  Future<void> _onFilterNotesByColor(FilterNotesByColorEvent event, Emitter<NotesState> emit) async {
    _currentFilterColor = event.color;

    final filteredNotes = _applyFiltersAndSorting(_cachedNotes);
    emit(NotesLoaded(
      notes: filteredNotes,
      currentSortBy: _currentSortBy,
      currentSortAscending: _currentSortAscending,
      currentFilterColor: _currentFilterColor,
      currentFilterTag: _currentFilterTag,
    ));
  }

  Future<void> _onFilterNotesByTag(FilterNotesByTagEvent event, Emitter<NotesState> emit) async {
    _currentFilterTag = event.tag;

    final filteredNotes = _applyFiltersAndSorting(_cachedNotes);
    emit(NotesLoaded(
      notes: filteredNotes,
      currentSortBy: _currentSortBy,
      currentSortAscending: _currentSortAscending,
      currentFilterColor: _currentFilterColor,
      currentFilterTag: _currentFilterTag,
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
    if (!_isInitialized) {
      emit(const NotesLoading());
    }

    _updateCurrentFilters(event);

    final result = await getNotesUseCase(NoParams());
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (notes) {
        _cachedNotes = List.from(notes);
        _isInitialized = true;
        final filteredNotes = _applyFiltersAndSorting(_cachedNotes);
        
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
      final updatedNote = event.note.copyWith(
        tags: currentTags,
        updatedAt: DateTime.now(),
      );

      final result = await updateNoteUseCase(UpdateNoteParams(note: updatedNote));
      result.fold(
        (failure) => emit(NotesError(failure: failure)),
        (note) {
          final index = _cachedNotes.indexWhere((n) => n.id == note.id);
          if (index != -1) {
            _cachedNotes[index] = note;
            final filteredNotes = _applyFiltersAndSorting(_cachedNotes);

            emit(NoteUpdatedSuccess(note: note));
            emit(NotesLoaded(
              notes: filteredNotes,
              currentSortBy: _currentSortBy,
              currentSortAscending: _currentSortAscending,
              currentFilterColor: _currentFilterColor,
              currentFilterTag: _currentFilterTag,
            ));
          }
        },
      );
    }
  }

  Future<void> _onReorderNotes(ReorderNotesEvent event, Emitter<NotesState> emit) async {
    final notes = List<NoteEntity>.from(event.notes);

    // Optimized reordering with batch update
    if (event.oldIndex < event.newIndex) {
      notes.insert(event.newIndex - 1, notes.removeAt(event.oldIndex));
    } else {
      notes.insert(event.newIndex, notes.removeAt(event.oldIndex));
    }

    // Update order for affected notes
    final updatedNotes = <NoteEntity>[];
    for (int i = 0; i < notes.length; i++) {
      if (notes[i].order != i) {
        updatedNotes.add(notes[i].copyWith(order: i, updatedAt: DateTime.now()));
      }
    }

    // Batch update (would need to implement batch update in use case)
    for (final note in updatedNotes) {
      final result = await updateNoteUseCase(UpdateNoteParams(note: note));
      result.fold(
        (failure) => emit(NotesError(failure: failure)),
        (updatedNote) {
          final index = _cachedNotes.indexWhere((n) => n.id == updatedNote.id);
          if (index != -1) {
            _cachedNotes[index] = updatedNote;
          }
        },
      );
    }

    final filteredNotes = _applyFiltersAndSorting(_cachedNotes);
    emit(NotesLoaded(
      notes: filteredNotes,
      currentSortBy: _currentSortBy,
      currentSortAscending: _currentSortAscending,
      currentFilterColor: _currentFilterColor,
      currentFilterTag: _currentFilterTag,
    ));
  }

  Future<void> _onSearchNotes(SearchNotesEvent event, Emitter<NotesState> emit) async {
    emit(const NotesLoading());
    
    if (event.query.isEmpty) {
      // Return to filtered view of all notes
      final filteredNotes = _applyFiltersAndSorting(_cachedNotes);
      emit(NotesLoaded(
        notes: filteredNotes,
        currentSortBy: _currentSortBy,
        currentSortAscending: _currentSortAscending,
        currentFilterColor: _currentFilterColor,
        currentFilterTag: _currentFilterTag,
      ));
      return;
    }

    final result = await searchNotesUseCase(SearchNotesParams(query: event.query));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (notes) {
        emit(NotesLoaded(
          notes: notes,
          currentSortBy: _currentSortBy,
          currentSortAscending: _currentSortAscending,
          currentFilterColor: _currentFilterColor,
          currentFilterTag: _currentFilterTag,
        ));
      },
    );
  }

  Future<void> _onSortNotes(SortNotesEvent event, Emitter<NotesState> emit) async {
    _currentSortBy = event.sortBy;
    _currentSortAscending = event.ascending;

    final filteredNotes = _applyFiltersAndSorting(_cachedNotes);
    emit(NotesLoaded(
      notes: filteredNotes,
      currentSortBy: _currentSortBy,
      currentSortAscending: _currentSortAscending,
      currentFilterColor: _currentFilterColor,
      currentFilterTag: _currentFilterTag,
    ));
  }

  Future<void> _onTogglePinNote(TogglePinNoteEvent event, Emitter<NotesState> emit) async {
    final updatedNote = event.note.copyWith(
      isPinned: !event.note.isPinned,
      updatedAt: DateTime.now(),
    );
    
    final result = await updateNoteUseCase(UpdateNoteParams(note: updatedNote));
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (note) {
        // Optimized: Update in cache
        final index = _cachedNotes.indexWhere((n) => n.id == note.id);
        if (index != -1) {
          _cachedNotes[index] = note;
          final filteredNotes = _applyFiltersAndSorting(_cachedNotes);
          
          emit(NoteUpdatedSuccess(note: note));
          emit(NotesLoaded(
            notes: filteredNotes,
            currentSortBy: _currentSortBy,
            currentSortAscending: _currentSortAscending,
            currentFilterColor: _currentFilterColor,
            currentFilterTag: _currentFilterTag,
          ));
        }
      },
    );
  }

  Future<void> _onUpdateNote(UpdateNoteEvent event, Emitter<NotesState> emit) async {
    final updatedNote = event.note.copyWith(updatedAt: DateTime.now());
    final result = await updateNoteUseCase(UpdateNoteParams(note: updatedNote));
    
    result.fold(
      (failure) => emit(NotesError(failure: failure)),
      (note) {
        // Optimized: Update in cache instead of full reload
        final index = _cachedNotes.indexWhere((n) => n.id == note.id);
        if (index != -1) {
          _cachedNotes[index] = note;
          final filteredNotes = _applyFiltersAndSorting(_cachedNotes);
          
          emit(NoteUpdatedSuccess(note: note));
          emit(NotesLoaded(
            notes: filteredNotes,
            currentSortBy: _currentSortBy,
            currentSortAscending: _currentSortAscending,
            currentFilterColor: _currentFilterColor,
            currentFilterTag: _currentFilterTag,
          ));
        }
      },
    );
  }

  // Helper methods
  void _updateCurrentFilters(LoadNotes event) {
    _currentSortBy = event.sortBy ?? _currentSortBy;
    _currentSortAscending = event.sortAscending ?? _currentSortAscending;
    _currentFilterColor = event.filterColor;
    _currentFilterTag = event.filterTag;
  }
}
