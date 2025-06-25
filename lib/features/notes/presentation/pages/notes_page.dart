import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zenlearn/core/routes/app_routes.dart'; // NEW: Import the file where routeObserver is defined
import 'package:zenlearn/core/widgets/app_scaffold.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_events.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_states.dart';
import 'package:zenlearn/features/notes/presentation/widgets/note_card.dart';
import 'package:zenlearn/features/notes/domain/entities/note_entity.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> with RouteAware, TickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<NoteEntity> _notes = [];
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));
    _loadNotes(); // Initial load when the page is first created
    
    // Animate FAB entrance
    Future.delayed(const Duration(milliseconds: 300), () {
      _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    _loadNotes(); // أعد تحميل الملاحظات عند العودة إلى هذه الصفحة
  }

  @override
  void didPush() {
    // يمكن استدعاؤه هنا إذا كنت تريد التأكد من التحميل عند الدفع الأول
  }

  void _loadNotes() {
    context.read<NotesBloc>().add(const LoadNotes());
  }

  void _updateNotesList(List<NoteEntity> newNotes) {
    final oldNotes = List<NoteEntity>.from(_notes);
    
    // Find notes that were added
    for (int i = 0; i < newNotes.length; i++) {
      final note = newNotes[i];
      if (!oldNotes.any((oldNote) => oldNote.id == note.id)) {
        _notes.insert(i, note);
        _listKey.currentState?.insertItem(i, duration: const Duration(milliseconds: 300));
      }
    }
    
    // Find notes that were removed
    for (int i = oldNotes.length - 1; i >= 0; i--) {
      final oldNote = oldNotes[i];
      if (!newNotes.any((note) => note.id == oldNote.id)) {
        final removedNote = _notes.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => _buildNoteItem(removedNote, animation),
          duration: const Duration(milliseconds: 300),
        );
      }
    }
    
    // Update existing notes (for pin status changes, etc.)
    for (int i = 0; i < _notes.length; i++) {
      final currentNote = _notes[i];
      final updatedNote = newNotes.firstWhere(
        (note) => note.id == currentNote.id,
        orElse: () => currentNote,
      );
      if (updatedNote != currentNote) {
        _notes[i] = updatedNote;
      }
    }
  }

  Widget _buildNoteItem(NoteEntity note, Animation<double> animation) {
    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOut)),
      ),
      child: FadeTransition(
        opacity: animation,
        child: NoteCard(
          note: note,
          onTap: () {
            context.go('/notes/view/${note.id}');
          },
          onTogglePin: () {
            context.read<NotesBloc>().add(TogglePinNoteEvent(note: note));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ملاحظاتي',
      actions: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: IconButton(
            key: const ValueKey('search_button'),
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ),
      ],
      body: BlocConsumer<NotesBloc, NotesState>(
        listener: (context, state) {
          if (state is NotesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطأ: ${state.failure.message ?? "حدث خطأ غير معروف"}'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          } else if (state is NotesLoaded) {
            _updateNotesList(state.notes);
          }
        },
        builder: (context, state) {
          if (state is NotesLoading && _notes.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is NotesLoaded || _notes.isNotEmpty) {
            if (_notes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.note_add_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد ملاحظات بعد',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'انقر على + لإضافة ملاحظة جديدة!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }
            return AnimatedList(
              key: _listKey,
              initialItemCount: _notes.length,
              padding: const EdgeInsets.only(top: 8.0, bottom: 80.0),
              itemBuilder: (context, index, animation) {
                if (index >= _notes.length) return const SizedBox.shrink();
                return _buildNoteItem(_notes[index], animation);
              },
            );
          } else if (state is NotesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'فشل تحميل الملاحظات',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.red[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.failure.message ?? "حدث خطأ غير معروف",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadNotes,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('ابدأ بإضافة ملاحظاتك!'));
        },
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: FloatingActionButton.extended(
          onPressed: () {
            context.go('/notes/add');
          },
          icon: const Icon(Icons.add),
          label: const Text('ملاحظة جديدة'),
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
      ),
    );
  }
}
