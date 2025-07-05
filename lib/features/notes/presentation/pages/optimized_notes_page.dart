import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zenlearn/core/widgets/app_scaffold.dart';
import 'package:zenlearn/features/notes/domain/entities/note_entity.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_events.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_states.dart';

import '../widgets/enhanced_filter_bar.dart';
import '../widgets/notes_list_widget.dart';
import '../widgets/notes_search_bar.dart';
import '../widgets/notes_state_widgets.dart';

/// A grid view variant of the notes page
class NotesGridPage extends StatelessWidget {
  const NotesGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ملاحظاتي - عرض الشبكة',
      body: Column(
        children: [
          const NotesSearchBar(),
          Expanded(
            child: BlocBuilder<NotesBloc, NotesState>(
              builder: (context, state) {
                if (state is NotesLoading) {
                  return const NotesLoadingWidget();
                }
                
                if (state is NotesError) {
                  return NotesErrorWidget(
                    failure: state.failure,
                    onRetry: () => context.read<NotesBloc>().add(const LoadNotes()),
                  );
                }
                
                if (state is NotesLoaded) {
                  if (state.notes.isEmpty) {
                    return NotesEmptyWidget(
                      onAction: () => context.go('/notes/add'),
                    );
                  }
                  
                  return NotesGridWidget(
                    notes: state.notes,
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(16),
                  );
                }
                
                return const NotesEmptyWidget();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/notes/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Optimized notes page with extracted components and improved performance
class OptimizedNotesPage extends StatefulWidget {
  const OptimizedNotesPage({super.key});

  @override
  State<OptimizedNotesPage> createState() => _OptimizedNotesPageState();
}

/// A simplified notes page for basic use cases
class SimpleNotesPage extends StatelessWidget {
  const SimpleNotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ملاحظاتي',
      body: Column(
        children: [
          const NotesSearchBar(),
          Expanded(
            child: BlocBuilder<NotesBloc, NotesState>(
              builder: (context, state) {
                if (state is NotesLoading) {
                  return const NotesLoadingWidget();
                }
                
                if (state is NotesError) {
                  return NotesErrorWidget(
                    failure: state.failure,
                    onRetry: () => context.read<NotesBloc>().add(const LoadNotes()),
                  );
                }
                
                if (state is NotesLoaded) {
                  if (state.notes.isEmpty) {
                    return NotesEmptyWidget(
                      onAction: () => context.go('/notes/add'),
                    );
                  }
                  
                  return NotesListWidget(
                    notes: state.notes,
                    padding: const EdgeInsets.all(16),
                  );
                }
                
                return const NotesEmptyWidget();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/notes/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _OptimizedNotesPageState extends State<OptimizedNotesPage>
    with TickerProviderStateMixin, RouteAware {

  static const Duration _searchDebounceDelay = Duration(milliseconds: 300);
  
  static const Duration _reorderDebounceDelay = Duration(milliseconds: 500);
  // Animation controllers
  late AnimationController _fabAnimationController;

  late AnimationController _filterAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _filterSlideAnimation;
  // Current state
  List<NoteEntity> _notes = [];
  List<NoteEntity> _allNotes = [];
  String? _currentSortBy;
  bool _currentSortAscending = true;
  int? _currentFilterColor;

  String? _currentFilterTag;

  bool _isSearching = false;
  String _searchQuery = '';
  // Reordering state
  final List<NoteEntity> _pinnedNotes = [];
  final List<NoteEntity> _unpinnedNotes = [];
  bool _isReordering = false;
  Timer? _reorderDebounceTimer;
  // Search debouncing
  Timer? _searchDebounceTimer;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ملاحظاتي',
      body: Column(
        children: [
          // Enhanced Search Bar
          NotesSearchBar(
            initialQuery: _searchQuery,
            showSearchResults: _isSearching,
            searchResultsCount: _isSearching ? _notes.length : 0,
            onSearchChanged: (query) {
              _handleSearchQueryChanged(query);
            },
            onClear: () {
              _clearSearch();
            },
          ),
          
          // Enhanced Filter Bar
          EnhancedFilterBar(
            currentSortBy: _currentSortBy,
            currentSortAscending: _currentSortAscending,
            currentFilterColor: _currentFilterColor,
            currentFilterTag: _currentFilterTag,
            availableTags: _getAvailableTags(),
            totalNotesCount: _allNotes.length,
            filteredNotesCount: _notes.length,
            onRefresh: _loadNotes,
            slideAnimation: _filterSlideAnimation,
          ),
          
          // Notes List
          Expanded(
            child: BlocConsumer<NotesBloc, NotesState>(
              listener: (context, state) {
                print('🎯 BLoC Listener - State received: ${state.runtimeType}');

                if (state is NotesLoaded) {
                  print('🎯 NotesLoaded - notes count: ${state.notes.length}');
                  print('🎯 Before _updateNotesList: _isSearching=$_isSearching, _searchQuery="$_searchQuery"');

                  _updateNotesList(state.notes);
                  _currentSortBy = state.currentSortBy;
                  _currentSortAscending = state.currentSortAscending ?? true;
                  _currentFilterColor = state.currentFilterColor;
                  _currentFilterTag = state.currentFilterTag;

                  // Reset search state when loading regular notes (not search results)
                  print('🎯 Calling _resetSearchState()');
                  _resetSearchState();
                  print('🎯 After _resetSearchState: _isSearching=$_isSearching');

                } else if (state is NotesSearchLoaded) {
                  print('🎯 NotesSearchLoaded - query: "${state.query}", results: ${state.searchResults.length}');
                  // Handle search results
                  setState(() {
                    _notes = state.searchResults;
                    _searchQuery = state.query;
                    _isSearching = state.query.isNotEmpty;
                    print('🎯 Search results setState: _isSearching=$_isSearching, _searchQuery="$_searchQuery"');
                  });
                } else if (state is NotesError) {
                  print('🎯 NotesError received');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('حدث خطأ: ${_getErrorMessage(state.failure)}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return _buildNotesContent(state);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: FloatingActionButton(
          onPressed: () => context.go('/notes/add'),
          tooltip: 'إضافة ملاحظة جديدة',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Register with RouteObserver for proper lifecycle management
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      // routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // Called when returning to this page from another page
    _loadNotes();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _filterAnimationController.dispose();
    _searchDebounceTimer?.cancel();
    _reorderDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadNotes();
  }



  /// Builds a drag handle that enables dragging only when pressed
  Widget _buildDragHandle(int index) {
    return ReorderableDragStartListener(
      index: index,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(
          Icons.drag_handle,
          color: Colors.grey[600],
          size: 20,
        ),
      ),
    );
  }



  /// Builds the trailing widget for note cards (pin icon + optional drag handle)
  Widget _buildNoteCardTrailing(NoteEntity note, bool canReorder, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (note.isPinned)
          Icon(Icons.push_pin, size: 16, color: Colors.orange[700]),
        if (canReorder) ...[
          const SizedBox(width: 8),
          _buildDragHandle(index),
        ],
      ],
    );
  }

  Widget _buildNotesContent(NotesState state) {
    // Handle loading states
    if (state is NotesLoading) {
      if (_notes.isEmpty) {
        final message = _isSearching
            ? 'جاري البحث في الملاحظات...'
            : 'جاري تحميل الملاحظات...';
        return NotesLoadingWidget(message: message);
      } else {
        // Show existing notes with loading indicator for search
        return Stack(
          children: [
            _buildNotesList(),
            if (_isSearching)
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
        onRetry: _isSearching ? () => _handleSearchQueryChanged(_searchQuery) : _loadNotes,
      );
    }

    // Handle search results
    if (state is NotesSearchLoaded) {
      if (state.searchResults.isEmpty) {
        return NotesSearchEmptyWidget(
          searchQuery: state.query,
          onClearSearch: _clearSearch,
        );
      }
      return _buildNotesList();
    }
    
    if (_notes.isEmpty) {
      if (_isSearching && _searchQuery.isNotEmpty) {
        return NotesSearchEmptyWidget(
          searchQuery: _searchQuery,
          onClearSearch: _clearSearch,
        );
      }
      
      if (_currentFilterColor != null || _currentFilterTag != null) {
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

  /// Builds the notes list with pull-to-refresh functionality and advanced reordering
  Widget _buildNotesList() {
    return RefreshIndicator(
      onRefresh: () async {
        if (_isSearching && _searchQuery.isNotEmpty) {
          _handleSearchQueryChanged(_searchQuery);
        } else {
          _loadNotes();
        }
        // Wait a bit for the animation
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: _buildReorderableNotesList(),
    );
  }

  /// Builds the advanced reorderable notes list with separate sections
  Widget _buildReorderableNotesList() {
    final canReorder = !_isSearching &&
                      _currentFilterColor == null &&
                      _currentFilterTag == null;

    print('🏗️ _buildReorderableNotesList called');
    print('🏗️ _isSearching: $_isSearching');
    print('🏗️ _currentFilterColor: $_currentFilterColor');
    print('🏗️ _currentFilterTag: $_currentFilterTag');
    print('🏗️ canReorder: $canReorder');
    print('🏗️ _notes.length: ${_notes.length}');
    print('🏗️ _pinnedNotes.length: ${_pinnedNotes.length}');
    print('🏗️ _unpinnedNotes.length: ${_unpinnedNotes.length}');

    if (!canReorder) {
      print('🏗️ Rendering ListView.builder (non-reorderable)');
      // Use unified note cards when reordering is disabled
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          return _buildUnifiedNoteCard(
            note: _notes[index],
            index: index,
            canReorder: false,
          );
        },
      );
    }

    print('🏗️ Rendering CustomScrollView with SliverReorderableList (reorderable)');
    // Continue with reorderable view...

    return Stack(
      children: [
        CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
        // Pinned notes section
        if (_pinnedNotes.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _buildSectionHeader('الملاحظات المثبتة', _pinnedNotes.length),
          ),
          SliverReorderableList(
            itemCount: _pinnedNotes.length,
            onReorder: (oldIndex, newIndex) => _handlePinnedNotesReorder(oldIndex, newIndex),
            proxyDecorator: _buildReorderProxy,
            itemBuilder: (context, index) {
              // Ensure index is within bounds
              if (index >= _pinnedNotes.length) {
                return const SizedBox.shrink();
              }

              return _buildUnifiedNoteCard(
                note: _pinnedNotes[index],
                index: index,
                canReorder: true,
                isPinnedSection: true,
              );
            },
          ),
        ],

        // Unpinned notes section
        if (_unpinnedNotes.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _buildSectionHeader('الملاحظات العادية', _unpinnedNotes.length),
          ),
          SliverReorderableList(
            itemCount: _unpinnedNotes.length,
            onReorder: (oldIndex, newIndex) => _handleUnpinnedNotesReorder(oldIndex, newIndex),
            proxyDecorator: _buildReorderProxy,
            itemBuilder: (context, index) {
              // Ensure index is within bounds
              if (index >= _unpinnedNotes.length) {
                return const SizedBox.shrink();
              }

              return _buildUnifiedNoteCard(
                note: _unpinnedNotes[index],
                index: index,
                canReorder: true,
                isPinnedSection: false,
              );
            },
          ),
        ],

        // Empty state if no notes
        if (_pinnedNotes.isEmpty && _unpinnedNotes.isEmpty)
          const SliverToBoxAdapter(
            child: SizedBox(height: 200),
          ),
      ],
    ),

        // Reordering indicator
        if (_isReordering)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              color: Theme.of(context).primaryColor,
              child: const LinearProgressIndicator(),
            ),
          ),
      ],
    );
  }

  /// Builds a proxy decorator for reordering visual feedback
  Widget _buildReorderProxy(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double elevation = Tween<double>(
          begin: 2.0,
          end: 8.0,
        ).evaluate(animation);

        final double scale = Tween<double>(
          begin: 1.0,
          end: 1.05,
        ).evaluate(animation);

        return Transform.scale(
          scale: scale,
          child: Material(
            elevation: elevation,
            borderRadius: BorderRadius.circular(8),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Builds a section header for pinned/unpinned notes
  Widget _buildSectionHeader(String title, int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(
            title.contains('المثبتة') ? Icons.push_pin : Icons.note,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a unified note card that works for both reorderable and non-reorderable lists
  Widget _buildUnifiedNoteCard({
    required NoteEntity note,
    required int index,
    required bool canReorder,
    bool isPinnedSection = false,
  }) {
    // Create a unique, stable key for each note item
    final String keyPrefix = isPinnedSection ? 'pinned' : 'unpinned';
    final String uniqueKey = '${keyPrefix}_${note.id}_${note.hashCode}';

    // Build the core note card content
    final Widget noteCardContent = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 2,
        child: ListTile(
          leading: Container(
            width: 4,
            height: double.infinity,
            decoration: BoxDecoration(
              color: note.color != null ? Color(note.color!) : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          title: Text(
            note.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (note.tags != null && note.tags!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: note.tags!.take(3).map((tag) => Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 10)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
                ),
              ],
            ],
          ),
          trailing: _buildNoteCardTrailing(note, canReorder, index),
          onTap: () => context.go("/notes/view/${note.id}"),
        ),
      ),
    );

    // Wrap with reorderable functionality if needed
    if (canReorder) {
      return ReorderableDragStartListener(
        key: ValueKey(uniqueKey),
        index: index,
        enabled: false, // Disable automatic drag from entire widget
        child: noteCardContent,
      );
    } else {
      return Container(
        key: ValueKey(uniqueKey),
        child: noteCardContent,
      );
    }
  }

  /// Clears the search and reloads all notes
  void _clearSearch() {
    print('🧹 _clearSearch called');
    _searchDebounceTimer?.cancel();

    setState(() {
      _searchQuery = '';
      _isSearching = false;
    });

    // Force immediate restoration of reorderable view
    _restoreReorderableView();
  }

  List<String> _getAvailableTags() {
    return _notes
        .expand((note) => note.tags ?? <String>[])
        .toSet()
        .toList()
        ..sort();
  }

  String _getErrorMessage(dynamic failure) {
    // Simple error message mapping
    return 'حدث خطأ غير متوقع';
  }

  /// Handles reordering of pinned notes
  void _handlePinnedNotesReorder(int oldIndex, int newIndex) {
    // Validate indices
    if (oldIndex < 0 || oldIndex >= _pinnedNotes.length ||
        newIndex < 0 || newIndex > _pinnedNotes.length) {
      return;
    }

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _isReordering = true;
      final note = _pinnedNotes.removeAt(oldIndex);
      _pinnedNotes.insert(newIndex, note);
    });

    // Debounce the BLoC event to avoid spam
    _reorderDebounceTimer?.cancel();
    _reorderDebounceTimer = Timer(_reorderDebounceDelay, () {
      if (mounted) {
        context.read<NotesBloc>().add(ReorderPinnedNotesEvent(
          oldIndex: oldIndex,
          newIndex: newIndex,
          pinnedNotes: _pinnedNotes,
        ));
        setState(() {
          _isReordering = false;
        });
      }
    });
  }

  /// Handles search query changes with debouncing
  void _handleSearchQueryChanged(String query) {
    print('🔍 _handleSearchQueryChanged called with query: "$query"');
    print('🔍 Current _isSearching: $_isSearching');

    // Cancel previous timer if it exists
    _searchDebounceTimer?.cancel();

    // Trim the query to handle whitespace-only input
    final trimmedQuery = query.trim();
    print('🔍 Trimmed query: "$trimmedQuery"');

    setState(() {
      _searchQuery = trimmedQuery;
      _isSearching = trimmedQuery.isNotEmpty;
      print('🔍 setState: _searchQuery="$_searchQuery", _isSearching=$_isSearching');
    });

    if (trimmedQuery.isEmpty) {
      print('🔍 Query is empty - clearing search state and loading notes');
      // If query is empty, clear search state and load all notes immediately
      setState(() {
        _isSearching = false;
        print('🔍 Final setState: _isSearching=$_isSearching');
      });

      // Force immediate restoration of reorderable view
      _restoreReorderableView();
      return;
    }

    print('🔍 Starting debounce timer for search');
    // Start new debounce timer for non-empty queries
    _searchDebounceTimer = Timer(_searchDebounceDelay, () {
      if (mounted && trimmedQuery.isNotEmpty) {
        print('🔍 Debounce timer fired - triggering SearchNotesEvent');
        // Trigger search event
        context.read<NotesBloc>().add(SearchNotesEvent(query: trimmedQuery));
      }
    });
  }

  /// Handles reordering of unpinned notes
  void _handleUnpinnedNotesReorder(int oldIndex, int newIndex) {
    // Validate indices
    if (oldIndex < 0 || oldIndex >= _unpinnedNotes.length ||
        newIndex < 0 || newIndex > _unpinnedNotes.length) {
      return;
    }

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _isReordering = true;
      final note = _unpinnedNotes.removeAt(oldIndex);
      _unpinnedNotes.insert(newIndex, note);
    });

    // Debounce the BLoC event to avoid spam
    _reorderDebounceTimer?.cancel();
    _reorderDebounceTimer = Timer(_reorderDebounceDelay, () {
      if (mounted) {
        context.read<NotesBloc>().add(ReorderUnpinnedNotesEvent(
          oldIndex: oldIndex,
          newIndex: newIndex,
          unpinnedNotes: _unpinnedNotes,
        ));
        setState(() {
          _isReordering = false;
        });
      }
    });
  }

  void _initializeAnimations() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));

    _filterSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    ));

    // Animate FAB entrance
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fabAnimationController.forward();
      }
    });
  }

  void _loadNotes() {
    context.read<NotesBloc>().add(LoadNotes(
      sortBy: _currentSortBy,
      sortAscending: _currentSortAscending,
      filterColor: _currentFilterColor,
      filterTag: _currentFilterTag,
    ));
  }

  /// Resets search state to ensure proper reorderable view restoration
  void _resetSearchState() {
    print('🔄 _resetSearchState called');
    print('🔄 _searchQuery: "$_searchQuery"');
    print('🔄 _isSearching: $_isSearching');

    if (_searchQuery.isEmpty && _isSearching) {
      print('🔄 Resetting _isSearching to false');
      setState(() {
        _isSearching = false;
      });
      print('🔄 After setState: _isSearching=$_isSearching');
    } else {
      print('🔄 No reset needed - conditions not met');
    }
  }

  /// Forces immediate restoration of reorderable view when search is cleared
  void _restoreReorderableView() {
    print('🔄 _restoreReorderableView called');

    // If we have cached notes, use them immediately
    if (_allNotes.isNotEmpty) {
      print('🔄 Using cached _allNotes (${_allNotes.length} notes)');
      setState(() {
        _notes = List.from(_allNotes);
        _isSearching = false;
      });
      _separateNotesByPinnedStatus();
      print('🔄 Immediate restoration complete');
    } else {
      print('🔄 No cached notes - triggering LoadNotes()');
      context.read<NotesBloc>().add(const LoadNotes());
    }
  }

  /// Separates notes into pinned and unpinned lists for reordering
  void _separateNotesByPinnedStatus() {
    // Temporarily use clear and addAll to work around final field issue
    _pinnedNotes.clear();
    _pinnedNotes.addAll(_notes.where((note) => note.isPinned).toList());
    _unpinnedNotes.clear();
    _unpinnedNotes.addAll(_notes.where((note) => !note.isPinned).toList());
  }

  void _updateNotesList(List<NoteEntity> notes) {
    print('📝 _updateNotesList called with ${notes.length} notes');
    print('📝 Current _isSearching: $_isSearching');

    if (mounted) {
      setState(() {
        _notes = notes;
        // Update all notes if this is not a filtered/search result
        if (!_isSearching && _currentFilterColor == null && _currentFilterTag == null) {
          _allNotes = List.from(notes);
          print('📝 Updated _allNotes with ${_allNotes.length} notes');
        }
        // Separate pinned and unpinned notes for reordering
        _separateNotesByPinnedStatus();
        print('📝 After separation: _pinnedNotes=${_pinnedNotes.length}, _unpinnedNotes=${_unpinnedNotes.length}');
      });
    }
  }
}
