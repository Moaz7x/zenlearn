import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/note_entity.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_events.dart';

/// Mixin for handling reordering functionality in notes pages
mixin NotesReorderingMixin<T extends StatefulWidget> on State<T> {
  // Reordering state
  final List<NoteEntity> _pinnedNotes = [];
  final List<NoteEntity> _unpinnedNotes = [];
  bool _isReordering = false;
  Timer? _reorderDebounceTimer;
  
  // Reordering configuration
  static const Duration _reorderDebounceDelay = Duration(milliseconds: 300);

  // Getters for reordering state
  List<NoteEntity> get pinnedNotes => _pinnedNotes;
  List<NoteEntity> get unpinnedNotes => _unpinnedNotes;
  bool get isReordering => _isReordering;

  /// Handles reordering of pinned notes
  void handlePinnedNotesReorder(int oldIndex, int newIndex) {
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

  /// Handles reordering of unpinned notes
  void handleUnpinnedNotesReorder(int oldIndex, int newIndex) {
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

  /// Separates notes into pinned and unpinned lists for reordering
  void separateNotesByPinnedStatus(List<NoteEntity> notes) {
    // Temporarily use clear and addAll to work around final field issue
    _pinnedNotes.clear();
    _pinnedNotes.addAll(notes.where((note) => note.isPinned).toList());
    _unpinnedNotes.clear();
    _unpinnedNotes.addAll(notes.where((note) => !note.isPinned).toList());
  }

  /// Updates reordering state
  void updateReorderingState(bool isReordering) {
    if (mounted) {
      setState(() {
        _isReordering = isReordering;
      });
    }
  }

  /// Cleanup method to be called in dispose
  void disposeReorderingMixin() {
    _reorderDebounceTimer?.cancel();
  }
}
