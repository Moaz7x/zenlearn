import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zenlearn/core/routes/app_routes.dart'; // NEW: Import the file where routeObserver is defined
import 'package:zenlearn/core/widgets/app_scaffold.dart';
import 'package:zenlearn/features/notes/domain/entities/note_entity.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_events.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_states.dart';
import 'package:zenlearn/features/notes/presentation/widgets/note_card.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> with RouteAware, TickerProviderStateMixin {
  final List<NoteEntity> _notes = [];
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

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
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // أيقونة كبيرة ومعبرة
                      Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.note_add_outlined,
                          size: 80,
                          color: Theme.of(context).primaryColor.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // عنوان رئيسي
                      Text(
                        'لا توجد ملاحظات بعد',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // رسالة توضيحية
                      Text(
                        'ابدأ رحلتك في تدوين الأفكار والملاحظات\nلتنظيم حياتك بشكل أفضل',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                              height: 1.5,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // زر إضافة ملاحظة جديدة
                      ElevatedButton.icon(
                        onPressed: () {
                          context.go('/notes/add');
                        },
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text(
                          'إضافة ملاحظة جديدة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 16.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          elevation: 4.0,
                          shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // نصائح سريعة
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.blue[600],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'نصيحة: يمكنك أيضاً استخدام الزر العائم في الأسفل لإضافة ملاحظات جديدة',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return BlocBuilder<NotesBloc, NotesState>(
                builder: (context, state) => state is NotesLoaded
                    ? ReorderableListView.builder(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 80.0),
                        itemCount: _notes.length,
                        onReorder: (oldIndex, newIndex) {
                          context.read<NotesBloc>().add(ReorderNotesEvent(
                                notes: state.notes,
                                oldIndex: oldIndex,
                                newIndex: newIndex > oldIndex ? newIndex - 1 : newIndex,
                              ));
                        },
                        itemBuilder: (context, index) {
                          if (index >= _notes.length) return const SizedBox.shrink();
                          return _buildNoteItem(_notes[index], index);
                        },
                      )
                    : ListView());
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

  @override
  void dispose() {
    _fabAnimationController.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

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

  Widget _buildNoteItem(NoteEntity note, int index) {
    return Container(
      key: ValueKey(note.id),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: NoteCard(
        note: note,
        onTap: () {
          context.go('/notes/view/${note.id}');
        },
        onTogglePin: () {
          context.read<NotesBloc>().add(TogglePinNoteEvent(note: note));
        },
      ),
    );
  }

  void _loadNotes() {
    context.read<NotesBloc>().add(const LoadNotes());
  }

  void _updateNotesList(List<NoteEntity> newNotes) {
    setState(() {
      _notes.clear();
      _notes.addAll(newNotes);
    });
  }
}
