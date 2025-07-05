import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/note_entity.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_events.dart';

/// Manages search functionality and state for notes
class NotesSearchManager extends ChangeNotifier {
  static const Duration _searchDebounceDelay = Duration(milliseconds: 300);

  Timer? _searchDebounceTimer;
  String _searchQuery = '';
  bool _isSearching = false;
  List<NoteEntity> _allNotes = [];
  List<NoteEntity> _notes = [];
  
  List<NoteEntity> get allNotes => _allNotes;
  bool get isSearching => _isSearching;
  List<NoteEntity> get notes => _notes;
  // Getters
  String get searchQuery => _searchQuery;

  /// Clears the search and reloads all notes
  void clearSearch(BuildContext context) {
    _searchDebounceTimer?.cancel();

    _searchQuery = '';
    _isSearching = false;
    notifyListeners();

    // Force immediate restoration of reorderable view
    restoreReorderableView(context);
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  /// Handles search query changes with debouncing
  void handleSearchQueryChanged(String query, BuildContext context) {
    // Cancel previous timer if it exists
    _searchDebounceTimer?.cancel();

    // Trim the query to handle whitespace-only input
    final trimmedQuery = query.trim();

    _searchQuery = trimmedQuery;
    _isSearching = trimmedQuery.isNotEmpty;
    notifyListeners();

    if (trimmedQuery.isEmpty) {
      // If query is empty, clear search state and load all notes immediately
      _isSearching = false;
      notifyListeners();
      
      // Force immediate restoration of reorderable view
      restoreReorderableView(context);
      return;
    }

    // Start new debounce timer for non-empty queries
    _searchDebounceTimer = Timer(_searchDebounceDelay, () {
      if (trimmedQuery.isNotEmpty) {
        // Trigger search event
        context.read<NotesBloc>().add(SearchNotesEvent(query: trimmedQuery));
      }
    });
  }

  /// Resets search state to ensure proper reorderable view restoration
  void resetSearchState() {
    if (_searchQuery.isEmpty && _isSearching) {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Forces immediate restoration of reorderable view when search is cleared
  void restoreReorderableView(BuildContext context) {
    // If we have cached notes, use them immediately
    if (_allNotes.isNotEmpty) {
      _notes = List.from(_allNotes);
      _isSearching = false;
      notifyListeners();
    } else {
      context.read<NotesBloc>().add(const LoadNotes());
    }
  }

  /// Updates the notes list
  void updateNotesList(List<NoteEntity> notes) {
    _notes = notes;
    // Update all notes if this is not a filtered/search result
    if (!_isSearching) {
      _allNotes = List.from(notes);
    }
    notifyListeners();
  }

  /// Updates search results
  void updateSearchResults(List<NoteEntity> searchResults, String query) {
    _notes = searchResults;
    _searchQuery = query;
    _isSearching = query.isNotEmpty;
    notifyListeners();
  }


}
