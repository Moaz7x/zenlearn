import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // NEW: Import go_router
import 'package:zenlearn/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_events.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_states.dart';
// import 'package:zenlearn/features/notes/presentation/pages/add_notes_page.dart'; // No direct import needed
// import 'package:zenlearn/features/notes/presentation/pages/note_view.dart'; // No direct import needed

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ملاحظاتي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality (e.g., show a search bar or navigate to a search page)
              // context.read<NotesBloc>().add(SearchNotesEvent(query: 'test'));
            },
          ),
        ],
      ),
      body: BlocConsumer<NotesBloc, NotesState>(
        listener: (context, state) {
          if (state is NotesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('خطأ: ${state.failure.message ?? "حدث خطأ غير معروف"}')),
            );
          }
          // You can add more listeners for success states if needed for specific UI feedback
        },
        builder: (context, state) {
          if (state is NotesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotesLoaded) {
            if (state.notes.isEmpty) {
              return const Center(
                child: Text('لا توجد ملاحظات بعد. انقر على + لإضافة واحدة!'),
              );
            }
            return ListView.builder(
              itemCount: state.notes.length,
              itemBuilder: (context, index) {
                final note = state.notes[index];
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
                      onPressed: () {
                        context.read<NotesBloc>().add(TogglePinNoteEvent(note: note));
                      },
                    ),
                    onTap: () {
                      // Navigate to note view page using GoRouter
                      context.go('/notes/view/${note.id}');
                    },
                  ),
                );
              },
            );
          } else if (state is NotesError) {
            return Center(
              child: Text('فشل تحميل الملاحظات: ${state.failure.message ?? "غير معروف"}'),
            );
          }
          return const Center(child: Text('ابدأ بإضافة ملاحظاتك!'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add notes page using GoRouter
          context.go('/notes/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<NotesBloc>().add(const LoadNotes());
  }
}
