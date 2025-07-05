import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/notes_bloc.dart';
import '../bloc/notes_events.dart';

/// Mixin for handling search functionality in notes pages
mixin NotesSearchMixin<T extends StatefulWidget> on State<T> {
  // Search state
  String _searchQuery = '';
  bool _isSearching = false;
  Timer? _searchDebounceTimer;
  
  // Search configuration
  static const Duration _searchDebounceDelay = Duration(milliseconds: 500);

  // Getters for search state
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;

  /// Handles search query changes with debouncing
  void handleSearchQueryChanged(String query) {
    // Cancel previous timer if it exists
    _searchDebounceTimer?.cancel();

    // Trim the query to handle whitespace-only input
    final trimmedQuery = query.trim();

    setState(() {
      _searchQuery = trimmedQuery;
      _isSearching = trimmedQuery.isNotEmpty;
    });

    if (trimmedQuery.isEmpty) {
      // If query is empty, clear search state and load all notes immediately
      setState(() {
        _isSearching = false;
      });

      // Force immediate restoration of reorderable view
      restoreReorderableView();
      return;
    }

    // Start new debounce timer for non-empty queries
    _searchDebounceTimer = Timer(_searchDebounceDelay, () {
      if (mounted && trimmedQuery.isNotEmpty) {
        // Trigger search event
        context.read<NotesBloc>().add(SearchNotesEvent(query: trimmedQuery));
      }
    });
  }

  /// Clears the search and reloads all notes
  void clearSearch() {
    _searchDebounceTimer?.cancel();

    setState(() {
      _searchQuery = '';
      _isSearching = false;
    });

    // Force immediate restoration of reorderable view
    restoreReorderableView();
  }

  /// Resets search state to ensure proper reorderable view restoration
  void resetSearchState() {
    if (mounted) {
      setState(() {
        _isSearching = false;
      });
    }
  }

  /// Forces immediate restoration of reorderable view when search is cleared
  void restoreReorderableView() {
    // Load all notes without search
    if (_searchQuery.isEmpty) {
      context.read<NotesBloc>().add(const LoadNotes());
    } else {
      context.read<NotesBloc>().add(const LoadNotes());
    }
  }

  /// Updates search state from external sources (like BLoC listeners)
  void updateSearchState(String query, bool searching) {
    if (mounted) {
      setState(() {
        _searchQuery = query;
        _isSearching = searching;
      });
    }
  }

  /// Cleanup method to be called in dispose
  void disposeSearchMixin() {
    _searchDebounceTimer?.cancel();
  }
}
