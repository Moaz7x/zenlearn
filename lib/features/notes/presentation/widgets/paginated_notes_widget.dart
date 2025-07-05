import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/note_entity.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_events.dart';
import '../bloc/notes_states.dart';
import 'notes_list_widget.dart';
import 'notes_state_widgets.dart';

/// A widget that implements pagination for large note lists
class PaginatedNotesWidget extends StatefulWidget {
  final int pageSize;
  final bool enablePullToRefresh;
  final Widget? emptyWidget;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;

  const PaginatedNotesWidget({
    super.key,
    this.pageSize = 20,
    this.enablePullToRefresh = true,
    this.emptyWidget,
    this.padding,
    this.physics,
  });

  @override
  State<PaginatedNotesWidget> createState() => _PaginatedNotesWidgetState();
}

class _PaginatedNotesWidgetState extends State<PaginatedNotesWidget> {
  final ScrollController _scrollController = ScrollController();
  final List<NoteEntity> _allNotes = [];
  
  bool _isLoading = false;
  bool _hasMoreData = true;
  int _currentPage = 0;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  void _loadInitialData() {
    _currentPage = 0;
    _allNotes.clear();
    _hasMoreData = true;
    _loadMoreData();
  }

  void _loadMoreData() {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
      _lastError = null;
    });

    // In a real implementation, you would call a paginated API
    // For now, we'll simulate pagination with the existing LoadNotes event
    context.read<NotesBloc>().add(const LoadNotes());
  }

  void _onRefresh() async {
    _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotesBloc, NotesState>(
      listener: (context, state) {
        if (state is NotesLoaded) {
          _handleNotesLoaded(state.notes);
        } else if (state is NotesError) {
          _handleError(state.failure.toString());
        }
      },
      child: _buildContent(),
    );
  }

  void _handleNotesLoaded(List<NoteEntity> newNotes) {
    setState(() {
      if (_currentPage == 0) {
        _allNotes.clear();
      }
      
      // Simulate pagination by taking a subset of notes
      final startIndex = _currentPage * widget.pageSize;
      final endIndex = (startIndex + widget.pageSize).clamp(0, newNotes.length);
      
      if (startIndex < newNotes.length) {
        final pageNotes = newNotes.sublist(startIndex, endIndex);
        _allNotes.addAll(pageNotes);
        _currentPage++;
        _hasMoreData = endIndex < newNotes.length;
      } else {
        _hasMoreData = false;
      }
      
      _isLoading = false;
    });
  }

  void _handleError(String error) {
    setState(() {
      _isLoading = false;
      _lastError = error;
    });
  }

  Widget _buildContent() {
    if (_allNotes.isEmpty && _isLoading) {
      return const NotesLoadingWidget(message: 'جاري تحميل الملاحظات...');
    }

    if (_allNotes.isEmpty && _lastError != null) {
      return NotesErrorWidget(
        failure: null,
        customMessage: _lastError,
        onRetry: _loadInitialData,
      );
    }

    if (_allNotes.isEmpty) {
      return widget.emptyWidget ?? const NotesEmptyWidget();
    }

    return widget.enablePullToRefresh
        ? RefreshIndicator(
            onRefresh: () async => _onRefresh(),
            child: _buildList(),
          )
        : _buildList();
  }

  Widget _buildList() {
    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding ?? const EdgeInsets.all(16),
      physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
      itemCount: _allNotes.length + (_hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _allNotes.length) {
          return _buildLoadingIndicator();
        }
        
        return _buildNoteItem(_allNotes[index], index);
      },
    );
  }

  Widget _buildNoteItem(NoteEntity note, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: NotesListWidget(
        notes: [note],
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_lastError != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'حدث خطأ في تحميل المزيد',
              style: TextStyle(color: Colors.red[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadMoreData,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}

/// A lazy loading notes widget that loads notes as needed
class LazyLoadingNotesWidget extends StatefulWidget {
  final int initialLoadCount;
  final int loadMoreCount;
  final Widget? emptyWidget;
  final EdgeInsets? padding;

  const LazyLoadingNotesWidget({
    super.key,
    this.initialLoadCount = 10,
    this.loadMoreCount = 5,
    this.emptyWidget,
    this.padding,
  });

  @override
  State<LazyLoadingNotesWidget> createState() => _LazyLoadingNotesWidgetState();
}

class _LazyLoadingNotesWidgetState extends State<LazyLoadingNotesWidget> {
  final ScrollController _scrollController = ScrollController();
  final List<NoteEntity> _displayedNotes = [];
  List<NoteEntity> _allNotes = [];
  
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 100) {
      _loadMoreNotes();
    }
  }

  void _loadMoreNotes() {
    if (_isLoadingMore || _displayedNotes.length >= _allNotes.length) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          final currentCount = _displayedNotes.length;
          final loadCount = widget.loadMoreCount;
          final endIndex = (currentCount + loadCount).clamp(0, _allNotes.length);
          
          _displayedNotes.addAll(_allNotes.sublist(currentCount, endIndex));
          _isLoadingMore = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotesBloc, NotesState>(
      listener: (context, state) {
        if (state is NotesLoaded) {
          setState(() {
            _allNotes = state.notes;
            _displayedNotes.clear();
            
            final initialCount = widget.initialLoadCount.clamp(0, _allNotes.length);
            _displayedNotes.addAll(_allNotes.take(initialCount));
          });
        }
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_displayedNotes.isEmpty) {
      return widget.emptyWidget ?? const NotesEmptyWidget();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding ?? const EdgeInsets.all(16),
      itemCount: _displayedNotes.length + (_hasMoreToLoad() ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _displayedNotes.length) {
          return _buildLoadMoreIndicator();
        }
        
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: NotesListWidget(
            notes: [_displayedNotes[index]],
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
          ),
        );
      },
    );
  }

  bool _hasMoreToLoad() {
    return _displayedNotes.length < _allNotes.length;
  }

  Widget _buildLoadMoreIndicator() {
    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ElevatedButton(
          onPressed: _loadMoreNotes,
          child: Text('تحميل المزيد (${_allNotes.length - _displayedNotes.length} متبقية)'),
        ),
      ),
    );
  }
}
