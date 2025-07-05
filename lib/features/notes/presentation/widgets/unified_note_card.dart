import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/note_entity.dart';

/// A unified note card that works for both reorderable and non-reorderable lists
class UnifiedNoteCard extends StatelessWidget {
  final NoteEntity note;
  final int index;
  final bool canReorder;
  final bool isPinnedSection;

  const UnifiedNoteCard({
    super.key,
    required this.note,
    required this.index,
    required this.canReorder,
    this.isPinnedSection = false,
  });

  @override
  Widget build(BuildContext context) {
    // Build semantic label for screen readers
    final String semanticLabel = _buildSemanticLabel();

    // Build the core note card content
    final Widget noteCardContent = Semantics(
      label: semanticLabel,
      button: true,
      enabled: true,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: note.color != null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(note.color!).withOpacity(0.1),
                      Color(note.color!).withOpacity(0.05),
                    ],
                  )
                : null,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Semantics(
                label: 'لون الملاحظة',
                child: Container(
                  width: 6,
                  height: 60,
                  decoration: BoxDecoration(
                    color: note.color != null ? Color(note.color!) : Theme.of(context).primaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: (note.color != null ? Color(note.color!) : Theme.of(context).primaryColor).withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            title: Text(
              note.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              semanticsLabel: 'عنوان الملاحظة: ${note.title}',
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  note.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  semanticsLabel: 'محتوى الملاحظة: ${note.content}',
                ),
                if (note.tags != null && note.tags!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Semantics(
                    label: 'علامات الملاحظة: ${note.tags!.join(', ')}',
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: note.tags!.take(3).map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
              ],
            ),
            trailing: _buildNoteCardTrailing(context),
            onTap: () => context.go("/notes/view/${note.id}"),
            ),
          ),
        ),
      ),
    );
    
    // Return the note card content
    return noteCardContent;
  }

  /// Builds a drag handle that enables dragging only when pressed
  Widget _buildDragHandle() {
    return Semantics(
      label: 'سحب لإعادة ترتيب الملاحظة',
      hint: 'اضغط واسحب لتغيير موضع الملاحظة',
      button: true,
      child: ReorderableDragStartListener(
        index: index,
        child: Container(
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.drag_handle,
            color: Colors.grey[600],
            size: 20,
            semanticLabel: 'مقبض السحب',
          ),
        ),
      ),
    );
  }

  /// Builds the trailing widget for note cards (pin icon + edit button + optional drag handle)
  Widget _buildNoteCardTrailing(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (note.isPinned)
          Semantics(
            label: 'ملاحظة مثبتة',
            child: Icon(
              Icons.push_pin,
              size: 16,
              color: Colors.orange[700],
              semanticLabel: 'أيقونة التثبيت',
            ),
          ),
        const SizedBox(width: 4),
        // Edit button
        Semantics(
          label: 'تعديل الملاحظة',
          hint: 'اضغط لتعديل هذه الملاحظة',
          button: true,
          child: InkWell(
            onTap: () => _navigateToEdit(context),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.edit,
                size: 16,
                color: Theme.of(context).primaryColor.withOpacity(0.7),
                semanticLabel: 'أيقونة التعديل',
              ),
            ),
          ),
        ),
        if (canReorder) ...[
          const SizedBox(width: 8),
          _buildDragHandle(),
        ],
      ],
    );
  }

  /// Builds a semantic label for screen readers
  String _buildSemanticLabel() {
    final StringBuffer buffer = StringBuffer();

    // Add note title
    buffer.write('ملاحظة: ${note.title}');

    // Add content if available
    if (note.content.isNotEmpty) {
      buffer.write('. المحتوى: ${note.content}');
    }

    // Add tags if available
    if (note.tags != null && note.tags!.isNotEmpty) {
      buffer.write('. العلامات: ${note.tags!.join(', ')}');
    }

    // Add pinned status
    if (note.isPinned) {
      buffer.write('. مثبتة');
    }

    // Add creation date
    buffer.write('. تاريخ الإنشاء: ${note.createdAt.toString()}');
  
    // Add interaction hint
    buffer.write('. اضغط للعرض');

    return buffer.toString();
  }

  /// Navigates to the edit page for this note
  void _navigateToEdit(BuildContext context) {
    context.go('/notes/edit/${note.id}', extra: note);
  }
}
