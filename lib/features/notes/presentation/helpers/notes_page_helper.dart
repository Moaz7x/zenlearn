import '../../domain/entities/note_entity.dart';

/// Utility class for notes page helper functions
class NotesPageHelper {
  /// Gets available tags from a list of notes
  static List<String> getAvailableTags(List<NoteEntity> notes) {
    return notes
        .expand((note) => note.tags ?? <String>[])
        .toSet()
        .toList()
        ..sort();
  }

  /// Gets a user-friendly error message from a failure
  static String getErrorMessage(dynamic failure) {
    // Simple error message mapping
    // In a real app, you might want to map specific failure types to specific messages
    return 'حدث خطأ غير متوقع';
  }

  /// Checks if notes can be reordered based on current state
  static bool canReorderNotes({
    required bool isSearching,
    required int? currentFilterColor,
    required String? currentFilterTag,
  }) {
    return !isSearching && 
           currentFilterColor == null && 
           currentFilterTag == null;
  }

  /// Filters notes by color
  static List<NoteEntity> filterNotesByColor(
    List<NoteEntity> notes, 
    int? colorFilter,
  ) {
    if (colorFilter == null) return notes;
    return notes.where((note) => note.color == colorFilter).toList();
  }

  /// Filters notes by tag
  static List<NoteEntity> filterNotesByTag(
    List<NoteEntity> notes, 
    String? tagFilter,
  ) {
    if (tagFilter == null) return notes;
    return notes.where((note) => 
      note.tags != null && note.tags!.contains(tagFilter)
    ).toList();
  }

  /// Separates notes into pinned and unpinned lists
  static Map<String, List<NoteEntity>> separateNotesByPinnedStatus(
    List<NoteEntity> notes,
  ) {
    final pinnedNotes = notes.where((note) => note.isPinned).toList();
    final unpinnedNotes = notes.where((note) => !note.isPinned).toList();
    
    return {
      'pinned': pinnedNotes,
      'unpinned': unpinnedNotes,
    };
  }

  /// Validates reorder indices
  static bool validateReorderIndices({
    required int oldIndex,
    required int newIndex,
    required int listLength,
  }) {
    return oldIndex >= 0 && 
           oldIndex < listLength &&
           newIndex >= 0 && 
           newIndex <= listLength;
  }

  /// Adjusts new index for reordering (Flutter's reorderable list behavior)
  static int adjustNewIndexForReordering(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      return newIndex - 1;
    }
    return newIndex;
  }

  /// Checks if a search query is valid (not empty after trimming)
  static bool isValidSearchQuery(String query) {
    return query.trim().isNotEmpty;
  }

  /// Trims and validates a search query
  static String sanitizeSearchQuery(String query) {
    return query.trim();
  }

  /// Determines the appropriate loading message based on context
  static String getLoadingMessage({
    required bool isSearching,
    String? searchQuery,
  }) {
    if (isSearching && searchQuery != null && searchQuery.isNotEmpty) {
      return 'جاري البحث في الملاحظات...';
    }
    return 'جاري تحميل الملاحظات...';
  }

  /// Determines if notes list should show empty state
  static bool shouldShowEmptyState({
    required List<NoteEntity> notes,
    required bool isSearching,
    required String searchQuery,
    required int? currentFilterColor,
    required String? currentFilterTag,
  }) {
    return notes.isEmpty && 
           !isSearching && 
           searchQuery.isEmpty &&
           currentFilterColor == null && 
           currentFilterTag == null;
  }

  /// Determines if search empty state should be shown
  static bool shouldShowSearchEmptyState({
    required List<NoteEntity> notes,
    required bool isSearching,
    required String searchQuery,
  }) {
    return notes.isEmpty && isSearching && searchQuery.isNotEmpty;
  }

  /// Determines if filter empty state should be shown
  static bool shouldShowFilterEmptyState({
    required List<NoteEntity> notes,
    required int? currentFilterColor,
    required String? currentFilterTag,
  }) {
    return notes.isEmpty && 
           (currentFilterColor != null || currentFilterTag != null);
  }
}
