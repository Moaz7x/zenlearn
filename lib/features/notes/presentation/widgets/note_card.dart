import 'package:flutter/material.dart';
import 'package:zenlearn/features/notes/domain/entities/note_entity.dart';

class NoteCard extends StatelessWidget {
  final NoteEntity note;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onTogglePin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      color: note.color != null ? Color(note.color!) : null,
      child: ListTile(
        title: Text(note.title),
        subtitle: Text(
          note.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: Icon(note.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
          onPressed: onTogglePin,
        ),
        onTap: onTap,
      ),
    );
  }
}
