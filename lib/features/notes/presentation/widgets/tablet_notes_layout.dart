import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/note_entity.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_states.dart';
import 'enhanced_filter_bar.dart';
import 'notes_search_bar.dart';

/// Tablet layout widget for notes page
class TabletNotesLayout extends StatelessWidget {
  final String? searchQuery;
  final bool isSearching;
  final List<NoteEntity> notes;
  final List<NoteEntity> allNotes;
  final String currentSortBy;
  final bool currentSortAscending;
  final int? currentFilterColor;
  final String? currentFilterTag;
  final List<String> availableTags;
  final Animation<double> filterSlideAnimation;
  final Function(String) onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onRefresh;
  final Function(List<NoteEntity>) onUpdateNotesList;
  final Function(String?, bool, int?, String?) onUpdateFilters;
  final VoidCallback onResetSearchState;
  final String Function(dynamic) getErrorMessage;
  final Widget Function(NotesState) buildNotesContent;

  const TabletNotesLayout({
    super.key,
    required this.searchQuery,
    required this.isSearching,
    required this.notes,
    required this.allNotes,
    required this.currentSortBy,
    required this.currentSortAscending,
    required this.currentFilterColor,
    required this.currentFilterTag,
    required this.availableTags,
    required this.filterSlideAnimation,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onRefresh,
    required this.onUpdateNotesList,
    required this.onUpdateFilters,
    required this.onResetSearchState,
    required this.getErrorMessage,
    required this.buildNotesContent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left sidebar with search and filters
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3, // 30% of screen width
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: NotesSearchBar(
                  initialQuery: searchQuery,
                  showSearchResults: isSearching,
                  searchResultsCount: isSearching ? notes.length : 0,
                  onSearchChanged: onSearchChanged,
                  onClear: onClearSearch,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: EnhancedFilterBar(
                  currentSortBy: currentSortBy,
                  currentSortAscending: currentSortAscending,
                  currentFilterColor: currentFilterColor,
                  currentFilterTag: currentFilterTag,
                  availableTags: availableTags,
                  totalNotesCount: allNotes.length,
                  filteredNotesCount: notes.length,
                  onRefresh: onRefresh,
                  slideAnimation: filterSlideAnimation,
                ),
              ),
            ],
          ),
        ),

        // Vertical divider
        const VerticalDivider(width: 1),

        // Main content area
        Expanded(
          child: BlocConsumer<NotesBloc, NotesState>(
            listener: (context, state) {
              if (state is NotesLoaded) {
                onUpdateNotesList(state.notes);
                onUpdateFilters(
                  state.currentSortBy,
                  state.currentSortAscending ?? true,
                  state.currentFilterColor,
                  state.currentFilterTag,
                );

                // Reset search state when loading regular notes (not search results)
                onResetSearchState();

              } else if (state is NotesSearchLoaded) {
                // Handle search results - this will be handled by parent
                // The parent will update its state based on this
              } else if (state is NotesError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('حدث خطأ: ${getErrorMessage(state.failure)}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              return buildNotesContent(state);
            },
          ),
        ),
      ],
    );
  }
}
