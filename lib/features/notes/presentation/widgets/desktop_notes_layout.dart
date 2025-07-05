import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/note_entity.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_events.dart';
import '../bloc/notes_states.dart';
import 'enhanced_filter_bar.dart';
import 'notes_search_bar.dart';
import 'notes_state_widgets.dart';

/// Desktop layout widget for notes page
class DesktopNotesLayout extends StatelessWidget {
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
  final Widget Function() buildDesktopNotesList;

  const DesktopNotesLayout({
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
    required this.buildDesktopNotesList,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left sidebar with search and filters
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.25, // 25% of screen width
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: NotesSearchBar(
                  initialQuery: searchQuery,
                  showSearchResults: isSearching,
                  searchResultsCount: isSearching ? notes.length : 0,
                  onSearchChanged: onSearchChanged,
                  onClear: onClearSearch,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
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

        // Main content area with grid layout for desktop
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
              return _buildDesktopNotesContent(context, state);
            },
          ),
        ),
      ],
    );
  }

  /// Builds the desktop notes content with grid layout
  Widget _buildDesktopNotesContent(BuildContext context, NotesState state) {
    // Handle loading states
    if (state is NotesLoading) {
      if (notes.isEmpty) {
        final message = isSearching
            ? 'جاري البحث في الملاحظات...'
            : 'جاري تحميل الملاحظات...';
        return NotesLoadingWidget(message: message);
      } else {
        return Stack(
          children: [
            buildDesktopNotesList(),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),
          ],
        );
      }
    }

    if (state is NotesError) {
      if (notes.isEmpty) {
        return NotesErrorWidget(
          customMessage: getErrorMessage(state.failure),
          onRetry: onRefresh,
        );
      } else {
        return Column(
          children: [
            Container(
              color: Colors.red[100],
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'خطأ في التحديث: ${getErrorMessage(state.failure)}',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: buildDesktopNotesList()),
          ],
        );
      }
    }

    if (state is NotesSearchLoaded && state.searchResults.isEmpty) {
      if (searchQuery?.isNotEmpty == true) {
        return NotesSearchEmptyWidget(
          searchQuery: searchQuery!,
          onClearSearch: onClearSearch,
        );
      }
      return buildDesktopNotesList();
    }

    if (notes.isEmpty) {
      if (isSearching && searchQuery?.isNotEmpty == true) {
        return NotesSearchEmptyWidget(
          searchQuery: searchQuery!,
          onClearSearch: onClearSearch,
        );
      }

      if (currentFilterColor != null || currentFilterTag != null) {
        final filterType = currentFilterTag != null ? 'العلامة' : 'اللون';
        final filterValue = currentFilterTag ?? 'اللون المحدد';

        return NotesFilterEmptyWidget(
          filterType: filterType,
          filterValue: filterValue,
          onClearFilter: () {
            context.read<NotesBloc>().add(const ClearTagFilterEvent());
            context.read<NotesBloc>().add(const ClearColorFilterEvent());
          },
        );
      }

      return NotesEmptyWidget(
        onAction: () => context.go('/notes/add'),
      );
    }

    return buildDesktopNotesList();
  }
}
