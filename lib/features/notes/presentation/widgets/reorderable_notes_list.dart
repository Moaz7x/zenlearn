import 'package:flutter/material.dart';

import '../../domain/entities/note_entity.dart';
import 'unified_note_card.dart';

/// A reorderable notes list widget that supports drag and drop functionality
class ReorderableNotesList extends StatelessWidget {
  final List<NoteEntity> pinnedNotes;
  final List<NoteEntity> unpinnedNotes;
  final Function(int oldIndex, int newIndex) onPinnedNotesReorder;
  final Function(int oldIndex, int newIndex) onUnpinnedNotesReorder;
  final bool isReordering;

  const ReorderableNotesList({
    super.key,
    required this.pinnedNotes,
    required this.unpinnedNotes,
    required this.onPinnedNotesReorder,
    required this.onUnpinnedNotesReorder,
    this.isReordering = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Pinned notes section
            if (pinnedNotes.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _buildSectionHeader('الملاحظات المثبتة', pinnedNotes.length),
              ),
              SliverReorderableList(
                itemCount: pinnedNotes.length,
                onReorder: onPinnedNotesReorder,
                proxyDecorator: _buildReorderProxy,
                itemBuilder: (context, index) {
                  // Ensure index is within bounds
                  if (index >= pinnedNotes.length) {
                    return const SizedBox.shrink();
                  }

                  return UnifiedNoteCard(
                    key: ValueKey('pinned_${pinnedNotes[index].id}_${pinnedNotes[index].hashCode}'),
                    note: pinnedNotes[index],
                    index: index,
                    canReorder: true,
                    isPinnedSection: true,
                  );
                },
              ),
            ],

            // Unpinned notes section
            if (unpinnedNotes.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _buildSectionHeader('الملاحظات العادية', unpinnedNotes.length),
              ),
              SliverReorderableList(
                itemCount: unpinnedNotes.length,
                onReorder: onUnpinnedNotesReorder,
                proxyDecorator: _buildReorderProxy,
                itemBuilder: (context, index) {
                  // Ensure index is within bounds
                  if (index >= unpinnedNotes.length) {
                    return const SizedBox.shrink();
                  }

                  return UnifiedNoteCard(
                    key: ValueKey('unpinned_${unpinnedNotes[index].id}_${unpinnedNotes[index].hashCode}'),
                    note: unpinnedNotes[index],
                    index: index,
                    canReorder: true,
                    isPinnedSection: false,
                  );
                },
              ),
            ],

            // Empty state if no notes
            if (pinnedNotes.isEmpty && unpinnedNotes.isEmpty)
              const SliverToBoxAdapter(
                child: SizedBox(height: 200),
              ),
          ],
        ),

        // Reordering indicator
        if (isReordering)
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
        final double elevation = Tween<double>(begin: 2.0, end: 8.0).evaluate(animation);
        final double scale = Tween<double>(begin: 1.0, end: 1.05).evaluate(animation);
        
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

  /// Builds a section header with title and count
  Widget _buildSectionHeader(String title, int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
