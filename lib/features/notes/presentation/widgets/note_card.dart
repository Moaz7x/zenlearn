import 'package:flutter/material.dart';
import 'package:zenlearn/features/notes/domain/entities/note_entity.dart';

class NoteCard extends StatelessWidget {
  // Changed to StatelessWidget
  final NoteEntity note;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onTogglePin,
  });

  // Removed all animation and long press state/methods (_animationController, _scaleAnimation, _isLongPressed, initState, dispose, _handleLongPressStart, _handleLongPressEnd, _handleTapCancel)

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Only handle tap
      // Removed onLongPressStart, onLongPressEnd, onTapCancel, onLongPressCancel
      child: Container(
        // Removed AnimatedBuilder and Transform.scale
        // margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            // Simplified boxShadow - no longer depends on _isLongPressed
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.0, // Fixed blurRadius
              offset: const Offset(0, 4),
              spreadRadius: 0, // Fixed spreadRadius
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16.0,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          color: note.color != null ? Color(note.color!) : Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title.isNotEmpty ? note.title : 'ملاحظة بدون عنوان',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Always show drag handle icon
                    Icon(
                      Icons.drag_handle,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: IconButton(
                        key: ValueKey(note.isPinned),
                        icon: Icon(
                          note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                          color: note.isPinned ? Theme.of(context).primaryColor : Colors.grey,
                        ),
                        onPressed: onTogglePin,
                        splashRadius: 20,
                      ),
                    ),
                  ],
                ),
                if (note.content.isNotEmpty) ...[
                  const SizedBox(height: 8.0),
                  Text(
                    note.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      _formatDate(note.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }
}
