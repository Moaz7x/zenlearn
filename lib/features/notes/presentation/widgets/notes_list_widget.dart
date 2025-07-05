import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/note_entity.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_events.dart';
import 'note_card.dart';

/// A reusable widget for displaying a list of notes with various layout options
class NotesListWidget extends StatelessWidget {
  final List<NoteEntity> notes;
  final bool isReorderable;
  final bool isSelectable;
  final Set<String> selectedNoteIds;
  final ValueChanged<Set<String>>? onSelectionChanged;
  final ScrollController? scrollController;
  final EdgeInsets? padding;
  final Widget? emptyWidget;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const NotesListWidget({
    super.key,
    required this.notes,
    this.isReorderable = false,
    this.isSelectable = false,
    this.selectedNoteIds = const {},
    this.onSelectionChanged,
    this.scrollController,
    this.padding,
    this.emptyWidget,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return emptyWidget ?? _buildEmptyState(context);
    }

    if (isReorderable) {
      return _buildReorderableList(context);
    }

    return _buildRegularList(context);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد ملاحظات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على + لإضافة ملاحظة جديدة',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularList(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: padding ?? const EdgeInsets.all(16),
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _buildNoteItem(context, note, index);
      },
    );
  }

  Widget _buildReorderableList(BuildContext context) {
    return ReorderableListView.builder(
      onReorder: (oldIndex, newIndex) {
        context.read<NotesBloc>().add(ReorderNotesEvent(
          oldIndex: oldIndex,
          newIndex: newIndex,
          notes: notes,
        ));
      },
      padding: padding ?? const EdgeInsets.all(16),
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ReorderableDelayedDragStartListener(
          key: ValueKey(note.id),
          index: index,
          child: _buildNoteItem(context, note, index),
        );
      },
    );
  }

  Widget _buildNoteItem(BuildContext context, NoteEntity note, int index) {
    final isSelected = selectedNoteIds.contains(note.id);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: isSelectable
          ? _buildSelectableNoteCard(context, note, isSelected)
          : _buildRegularNoteCard(context, note),
    );
  }

  Widget _buildRegularNoteCard(BuildContext context, NoteEntity note) {
    return NoteCard(
      note: note,
      onTap: () => context.go("/notes/view/${note.id}"),
      onTogglePin: () {
        context.read<NotesBloc>().add(TogglePinNoteEvent(note: note));
      },
      onAddTag: (tag) {
        context.read<NotesBloc>().add(AddTagToNoteEvent(note: note, tag: tag));
      },
      onRemoveTag: (tag) {
        context.read<NotesBloc>().add(RemoveTagFromNoteEvent(note: note, tag: tag));
      },
    );
  }

  Widget _buildSelectableNoteCard(BuildContext context, NoteEntity note, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (isSelectable) {
          final newSelection = Set<String>.from(selectedNoteIds);
          if (isSelected) {
            newSelection.remove(note.id);
          } else {
            newSelection.add(note.id);
          }
          onSelectionChanged?.call(newSelection);
        } else {
          context.go("/notes/view/${note.id}");
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: isSelected 
              ? Border.all(color: Theme.of(context).primaryColor, width: 2)
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            NoteCard(
              note: note,
              onTap: null, // Disable tap when in selection mode
              onTogglePin: () {
                context.read<NotesBloc>().add(TogglePinNoteEvent(note: note));
              },
              onAddTag: (tag) {
                context.read<NotesBloc>().add(AddTagToNoteEvent(note: note, tag: tag));
              },
              onRemoveTag: (tag) {
                context.read<NotesBloc>().add(RemoveTagFromNoteEvent(note: note, tag: tag));
              },
            ),
            if (isSelectable)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Theme.of(context).primaryColor 
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSelected ? Icons.check : Icons.circle_outlined,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A grid layout variant for notes
class NotesGridWidget extends StatelessWidget {
  final List<NoteEntity> notes;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final Widget? emptyWidget;
  final ScrollController? scrollController;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const NotesGridWidget({
    super.key,
    required this.notes,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.8,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.padding,
    this.emptyWidget,
    this.scrollController,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return emptyWidget ?? _buildEmptyState(context);
    }

    return GridView.builder(
      controller: scrollController,
      padding: padding ?? const EdgeInsets.all(16),
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          note: note,
          onTap: () => context.go("/notes/view/${note.id}"),
          onTogglePin: () {
            context.read<NotesBloc>().add(TogglePinNoteEvent(note: note));
          },
          onAddTag: (tag) {
            context.read<NotesBloc>().add(AddTagToNoteEvent(note: note, tag: tag));
          },
          onRemoveTag: (tag) {
            context.read<NotesBloc>().add(RemoveTagFromNoteEvent(note: note, tag: tag));
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.grid_view_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد ملاحظات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
