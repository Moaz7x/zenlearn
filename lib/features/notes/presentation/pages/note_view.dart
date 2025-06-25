import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // NEW: Import go_router
import 'package:intl/intl.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_events.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_states.dart';
// import 'package:zenlearn/features/notes/presentation/pages/add_notes_page.dart'; // No direct import needed if using GoRouter

class NoteViewPage extends StatefulWidget {
  final String noteId; // Changed to receive noteId

  const NoteViewPage({super.key, required this.noteId});

  @override
  State<NoteViewPage> createState() => _NoteViewPageState();
}

class _NoteViewPageState extends State<NoteViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عرض الملاحظة'),
        actions: [
          BlocBuilder<NotesBloc, NotesState>(
            builder: (context, state) {
              if (state is NoteLoadedById) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Navigate to AddNotesPage for editing, passing the note as extra
                    context.go('/notes/add', extra: state.note);
                  },
                );
              }
              return const SizedBox.shrink(); // Hide edit button if note not loaded
            },
          ),
          BlocBuilder<NotesBloc, NotesState>(
            builder: (context, state) {
              if (state is NoteLoadedById) {
                return IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _confirmDelete(context, state.note.id);
                  },
                );
              }
              return const SizedBox.shrink(); // Hide delete button if note not loaded
            },
          ),
        ],
      ),
      body: BlocConsumer<NotesBloc, NotesState>(
        listener: (context, state) {
          if (state is NoteDeletedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم حذف الملاحظة بنجاح!')),
            );
            context.pop(); // Go back using GoRouter
          } else if (state is NotesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('خطأ: ${state.failure.message ?? "حدث خطأ غير معروف"}')),
            );
          }
        },
        builder: (context, state) {
          if (state is NotesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NoteLoadedById) {
            final note = state.note;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'تم الإنشاء: ${DateFormat('yyyy-MM-dd HH:mm').format(note.createdAt)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (note.updatedAt != null)
                    Text(
                      'آخر تحديث: ${DateFormat('yyyy-MM-dd HH:mm').format(note.updatedAt!)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        note.content,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is NotesError) {
            return Center(
              child: Text('فشل تحميل الملاحظة: ${state.failure.message ?? "غير معروف"}'),
            );
          }
          return const Center(child: Text('جاري تحميل الملاحظة...'));
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Dispatch event to load the specific note
    context.read<NotesBloc>().add(GetNoteByIdEvent(noteId: widget.noteId));
  }

  void _confirmDelete(BuildContext context, String noteId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد أنك تريد حذف هذه الملاحظة؟'),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                context.read<NotesBloc>().add(DeleteNoteEvent(noteId: noteId));
              },
            ),
          ],
        );
      },
    );
  }
}
