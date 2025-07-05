import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/notes_bloc.dart';
import '../bloc/notes_events.dart';

/// A compact search bar variant for use in app bars
class CompactNotesSearchBar extends StatefulWidget {
  final String? initialQuery;
  final Duration debounceDuration;
  final String hintText;
  final bool enabled;
  final VoidCallback? onClear;

  const CompactNotesSearchBar({
    super.key,
    this.initialQuery,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.hintText = 'البحث...',
    this.enabled = true,
    this.onClear,
  });

  @override
  State<CompactNotesSearchBar> createState() => _CompactNotesSearchBarState();
}

/// A reusable search bar widget for notes with debouncing
class NotesSearchBar extends StatefulWidget {
  final String? initialQuery;
  final Duration debounceDuration;
  final String hintText;
  final bool enabled;
  final VoidCallback? onClear;
  final ValueChanged<String>? onSearchChanged;
  final bool showSearchResults;
  final int searchResultsCount;

  const NotesSearchBar({
    super.key,
    this.initialQuery,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.hintText = 'البحث في الملاحظات...',
    this.enabled = true,
    this.onClear,
    this.onSearchChanged,
    this.showSearchResults = false,
    this.searchResultsCount = 0,
  });

  @override
  State<NotesSearchBar> createState() => _NotesSearchBarState();
}

class _CompactNotesSearchBarState extends State<CompactNotesSearchBar> {
  late TextEditingController _searchController;
  Timer? _debounceTimer;
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: _searchController,
        enabled: widget.enabled,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: _isSearching
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  ),
                )
              : const Icon(Icons.search, size: 20, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                  onPressed: _clearSearch,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
          isDense: true,
        ),
        style: const TextStyle(fontSize: 14),
        textInputAction: TextInputAction.search,
        onSubmitted: (query) {
          _debounceTimer?.cancel();
          _performSearch(query.trim());
        },
        
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _searchController.addListener(_onSearchChanged);
  }

  void _clearSearch() {
    _searchController.clear();
    widget.onClear?.call();
    context.read<NotesBloc>().add(const LoadNotes());
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    
    _debounceTimer?.cancel();
    
    if (mounted) {
      setState(() {
        _isSearching = query.isNotEmpty;
      });
    }
    
    _debounceTimer = Timer(widget.debounceDuration, () {
      if (mounted) {
        _performSearch(query);
      }
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      context.read<NotesBloc>().add(const LoadNotes());
    } else {
      context.read<NotesBloc>().add(SearchNotesEvent(query: query));
    }
    
    if (mounted) {
      setState(() {
        _isSearching = false;
      });
    }
  }
}

class _NotesSearchBarState extends State<NotesSearchBar> {
  late TextEditingController _searchController;
  Timer? _debounceTimer;
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Semantics(
        label: 'حقل البحث في الملاحظات',
        hint: 'اكتب للبحث في الملاحظات',
        textField: true,
        child: TextField(
          controller: _searchController,
          enabled: widget.enabled,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            prefixIcon: _isSearching
                ? Semantics(
                    label: 'جاري البحث',
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : Semantics(
                    label: 'أيقونة البحث',
                    child: const Icon(Icons.search, color: Colors.grey),
                  ),
          suffixIcon: _searchController.text.isNotEmpty
              ? Semantics(
                  label: 'مسح البحث',
                  hint: 'اضغط لمسح نص البحث',
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: _clearSearch,
                    tooltip: 'مسح البحث',
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
        ),
        style: const TextStyle(fontSize: 16),
        textInputAction: TextInputAction.search,
        onSubmitted: (query) {
          _debounceTimer?.cancel();
          final trimmedQuery = query.trim();

          // Notify parent immediately on submit
          widget.onSearchChanged?.call(trimmedQuery);

          _performSearch(trimmedQuery);
        },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _searchController.addListener(_onSearchChanged);
  }

  void _clearSearch() {
    _searchController.clear();

    // Notify parent about the cleared search
    widget.onSearchChanged?.call('');

    // Call the onClear callback if provided
    widget.onClear?.call();

    // Also trigger BLoC event (for backward compatibility)
    context.read<NotesBloc>().add(const LoadNotes());
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Set searching state
    if (mounted) {
      setState(() {
        _isSearching = query.isNotEmpty;
      });
    }

    // Notify parent immediately when text changes
    // This ensures the parent page knows about manual text deletion
    widget.onSearchChanged?.call(query);

    // Start new timer for debouncing BLoC calls
    _debounceTimer = Timer(widget.debounceDuration, () {
      if (mounted) {
        _performSearch(query);
      }
    });
  }

  void _performSearch(String query) {
    // The parent page handles BLoC interactions through onSearchChanged callback
    // We keep this for backward compatibility, but the main logic is in the parent
    if (query.isEmpty) {
      // Load all notes when search is cleared
      context.read<NotesBloc>().add(const LoadNotes());
    } else {
      // Perform search
      context.read<NotesBloc>().add(SearchNotesEvent(query: query));
    }

    if (mounted) {
      setState(() {
        _isSearching = false;
      });
    }
  }
}
