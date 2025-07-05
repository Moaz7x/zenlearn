import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zenlearn/core/widgets/app_scaffold.dart';
import 'package:zenlearn/features/notes/domain/entities/note_entity.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_events.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_states.dart';

import '../helpers/notes_page_helper.dart';
import '../mixins/notes_animation_mixin.dart';
import '../mixins/notes_reordering_mixin.dart';
import '../mixins/notes_search_mixin.dart';
import '../widgets/desktop_notes_layout.dart';
import '../widgets/mobile_notes_layout.dart';
import '../widgets/notes_list_widget.dart';
import '../widgets/notes_state_widgets.dart';
import '../widgets/reorderable_notes_list.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/tablet_notes_layout.dart';
import '../widgets/unified_note_card.dart';

/// Refactored optimized notes page with clean separation of concerns
class RefactoredNotesPage extends StatefulWidget {
  const RefactoredNotesPage({super.key});

  @override
  State<RefactoredNotesPage> createState() => _RefactoredNotesPageState();
}

class _RefactoredNotesPageState extends State<RefactoredNotesPage>
    with TickerProviderStateMixin, RouteAware, NotesSearchMixin, NotesReorderingMixin, NotesAnimationMixin {

  // Current state
  List<NoteEntity> _notes = [];
  List<NoteEntity> _allNotes = [];
  String? _currentSortBy;
  bool _currentSortAscending = true;
  int? _currentFilterColor;
  String? _currentFilterTag;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ملاحظاتي',
      body: ResponsiveLayout(
        mobile: MobileNotesLayout(
          searchQuery: searchQuery,
          isSearching: isSearching,
          notes: _notes,
          allNotes: _allNotes,
          currentSortBy: _currentSortBy ?? 'createdAt',
          currentSortAscending: _currentSortAscending,
          currentFilterColor: _currentFilterColor,
          currentFilterTag: _currentFilterTag,
          availableTags: NotesPageHelper.getAvailableTags(_notes),
          filterSlideAnimation: filterSlideAnimation,
          onSearchChanged: handleSearchQueryChanged,
          onClearSearch: clearSearch,
          onRefresh: _loadNotes,
          onUpdateNotesList: _updateNotesList,
          onUpdateFilters: _updateFilters,
          onResetSearchState: resetSearchState,
          getErrorMessage: NotesPageHelper.getErrorMessage,
          buildNotesContent: _buildNotesContent,
        ),
        tablet: TabletNotesLayout(
          searchQuery: searchQuery,
          isSearching: isSearching,
          notes: _notes,
          allNotes: _allNotes,
          currentSortBy: _currentSortBy ?? 'createdAt',
          currentSortAscending: _currentSortAscending,
          currentFilterColor: _currentFilterColor,
          currentFilterTag: _currentFilterTag,
          availableTags: NotesPageHelper.getAvailableTags(_notes),
          filterSlideAnimation: filterSlideAnimation,
          onSearchChanged: handleSearchQueryChanged,
          onClearSearch: clearSearch,
          onRefresh: _loadNotes,
          onUpdateNotesList: _updateNotesList,
          onUpdateFilters: _updateFilters,
          onResetSearchState: resetSearchState,
          getErrorMessage: NotesPageHelper.getErrorMessage,
          buildNotesContent: _buildNotesContent,
        ),
        desktop: DesktopNotesLayout(
          searchQuery: searchQuery,
          isSearching: isSearching,
          notes: _notes,
          allNotes: _allNotes,
          currentSortBy: _currentSortBy ?? 'createdAt',
          currentSortAscending: _currentSortAscending,
          currentFilterColor: _currentFilterColor,
          currentFilterTag: _currentFilterTag,
          availableTags: NotesPageHelper.getAvailableTags(_notes),
          filterSlideAnimation: filterSlideAnimation,
          onSearchChanged: handleSearchQueryChanged,
          onClearSearch: clearSearch,
          onRefresh: _loadNotes,
          onUpdateNotesList: _updateNotesList,
          onUpdateFilters: _updateFilters,
          onResetSearchState: resetSearchState,
          getErrorMessage: NotesPageHelper.getErrorMessage,
          buildDesktopNotesList: _buildDesktopNotesList,
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: fabScaleAnimation,
        child: FloatingActionButton(
          onPressed: () => context.go('/notes/add'),
          tooltip: 'إضافة ملاحظة جديدة',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  @override
  void dispose() {
    disposeAnimationMixin();
    disposeSearchMixin();
    disposeReorderingMixin();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initializeAnimations();
    _loadNotes();
  }

  /// Builds the desktop notes list with grid layout
  Widget _buildDesktopNotesList() {
    return RefreshIndicator(
      onRefresh: () async {
        if (isSearching && searchQuery.isNotEmpty) {
          context.read<NotesBloc>().add(SearchNotesEvent(query: searchQuery));
        } else {
          _loadNotes();
        }
      },
      child: _buildDesktopReorderableNotesList(),
    );
  }

  /// Builds the desktop reorderable notes list using the existing widget component
  Widget _buildDesktopReorderableNotesList() {
    final canReorder = NotesPageHelper.canReorderNotes(
      isSearching: isSearching,
      currentFilterColor: _currentFilterColor,
      currentFilterTag: _currentFilterTag,
    );

    if (!canReorder) {
      // Use grid layout for desktop when reordering is disabled
      return ResponsiveGrid(
        key: const ValueKey('desktop_notes_grid'),
        desktopColumns: 3,
        tabletColumns: 2,
        mobileColumns: 1,
        spacing: 16,
        runSpacing: 16,
        children: _notes.asMap().entries.map((entry) {
          final index = entry.key;
          final note = entry.value;
          return UnifiedNoteCard(
            key: ValueKey('desktop_note_${note.id}'),
            note: note,
            index: index,
            canReorder: false,
          );
        }).toList(),
      );
    }

    // Use the existing ReorderableNotesList widget for reorderable desktop view
    return ReorderableNotesList(
      pinnedNotes: pinnedNotes,
      unpinnedNotes: unpinnedNotes,
      onPinnedNotesReorder: handlePinnedNotesReorder,
      onUnpinnedNotesReorder: handleUnpinnedNotesReorder,
      isReordering: isReordering,
    );
  }

  /// Builds the notes content with proper state handling
  Widget _buildNotesContent(NotesState state) {
    // Handle loading states
    if (state is NotesLoading) {
      if (_notes.isEmpty) {
        final message = NotesPageHelper.getLoadingMessage(
          isSearching: isSearching,
          searchQuery: searchQuery,
        );
        return NotesLoadingWidget(message: message);
      } else {
        return Stack(
          children: [
            _buildNotesList(),
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
      return NotesErrorWidget(
        failure: state.failure,
        onRetry: isSearching ? () => handleSearchQueryChanged(searchQuery) : _loadNotes,
      );
    }

    // Handle search results
    if (state is NotesSearchLoaded) {
      if (state.searchResults.isEmpty) {
        return NotesSearchEmptyWidget(
          searchQuery: state.query,
          onClearSearch: clearSearch,
        );
      }
      return _buildNotesList();
    }

    if (_notes.isEmpty) {
      if (NotesPageHelper.shouldShowSearchEmptyState(
        notes: _notes,
        isSearching: isSearching,
        searchQuery: searchQuery,
      )) {
        return NotesSearchEmptyWidget(
          searchQuery: searchQuery,
          onClearSearch: clearSearch,
        );
      }

      if (NotesPageHelper.shouldShowFilterEmptyState(
        notes: _notes,
        currentFilterColor: _currentFilterColor,
        currentFilterTag: _currentFilterTag,
      )) {
        final filterType = _currentFilterTag != null ? 'العلامة' : 'اللون';
        final filterValue = _currentFilterTag ?? 'اللون المحدد';

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

    return _buildNotesList();
  }

  /// Builds the notes list with pull-to-refresh functionality
  Widget _buildNotesList() {
    return RefreshIndicator(
      onRefresh: () async {
        if (isSearching && searchQuery.isNotEmpty) {
          handleSearchQueryChanged(searchQuery);
        } else {
          _loadNotes();
        }
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: _buildReorderableNotesList(),
    );
  }

  /// Builds the reorderable notes list using the existing widget component
  Widget _buildReorderableNotesList() {
    final canReorder = NotesPageHelper.canReorderNotes(
      isSearching: isSearching,
      currentFilterColor: _currentFilterColor,
      currentFilterTag: _currentFilterTag,
    );

    if (!canReorder) {
      // Use NotesListWidget for non-reorderable list
      return NotesListWidget(
        notes: _notes,
        isReorderable: false,
        padding: const EdgeInsets.all(16),
      );
    }

    // Use the existing ReorderableNotesList widget
    return ReorderableNotesList(
      pinnedNotes: pinnedNotes,
      unpinnedNotes: unpinnedNotes,
      onPinnedNotesReorder: handlePinnedNotesReorder,
      onUnpinnedNotesReorder: handleUnpinnedNotesReorder,
      isReordering: isReordering,
    );
  }

  void _loadNotes() {
    context.read<NotesBloc>().add(LoadNotes(
      sortBy: _currentSortBy,
      sortAscending: _currentSortAscending,
      filterColor: _currentFilterColor,
      filterTag: _currentFilterTag,
    ));
  }

  void _updateFilters(String? sortBy, bool sortAscending, int? filterColor, String? filterTag) {
    setState(() {
      _currentSortBy = sortBy;
      _currentSortAscending = sortAscending;
      _currentFilterColor = filterColor;
      _currentFilterTag = filterTag;
    });
  }

  void _updateNotesList(List<NoteEntity> notes) {
    if (mounted) {
      setState(() {
        _notes = notes;
        // Update all notes if this is not a filtered/search result
        if (!isSearching && _currentFilterColor == null && _currentFilterTag == null) {
          _allNotes = List.from(notes);
        }
        // Separate pinned and unpinned notes for reordering
        separateNotesByPinnedStatus(_notes);
      });
    }
  }
}
