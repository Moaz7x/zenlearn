import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zenlearn/core/routes/app_routes.dart';
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
  List<NoteEntity> _notes = [];
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  String? _currentSortBy; // 'date', 'title', 'pinned'
  bool _currentSortAscending = true;
  int? _currentFilterColor;
  String? _currentFilterTag;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    _loadNotes(); // Reload notes when returning to this page
  }

  @override
  void didPush() {
    // Can be called here if you want to ensure loading on first push
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  void _loadNotes() {
    context.read<NotesBloc>().add(LoadNotes(
          sortBy: _currentSortBy,
          sortAscending: _currentSortAscending,
          filterColor: _currentFilterColor,
          filterTag: _currentFilterTag,
        ));
  }

  void _updateNotesList(List<NoteEntity> newNotes) {
    setState(() {
      _notes = newNotes;
    });
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
            _currentSortBy = state.currentSortBy;
            _currentSortAscending = state.currentSortAscending ?? true;
            _currentFilterColor = state.currentFilterColor;
            _currentFilterTag = state.currentFilterTag;
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
                      Text(
                        'لا توجد ملاحظات بعد',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'ابدأ رحلتك في تدوين الأفكار والملاحظات\nلتنظيم حياتك بشكل أفضل',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                              height: 1.5,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
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
            return Column(
              children: [
                _buildFilterAndSortBar(context),
                Expanded(
                  child: BlocBuilder<NotesBloc, NotesState>(
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
                              proxyDecorator: (Widget child, int index, Animation<double> animation) {
                                return AnimatedBuilder(
                                  animation: animation,
                                  builder: (BuildContext context, Widget? child) {
                                    final double animValue = Curves.easeInOut.transform(animation.value);
                                    final double scale = 1.0 + (0.05 * animValue);
                                    final double blurRadius =
                                        8.0 + (4.0 * animValue);
                                    final double spreadRadius =
                                        0.0 + (2.0 * animValue);

                                    return Transform.scale(
                                      scale: scale,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                  0.1 + (0.05 * animValue)),
                                              blurRadius: blurRadius,
                                              offset: const Offset(0, 4),
                                              spreadRadius: spreadRadius,
                                            ),
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              blurRadius: 16.0,
                                              offset: const Offset(0, 8),
                                              spreadRadius: 0,
                                            ),
                                          ],
                                        ),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: child,
                                );
                              },
                            )
                          : ListView()),
                ),
              ],
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

  Widget _buildNoteItem(NoteEntity note, int index) {
    return ReorderableDelayedDragStartListener(
      key: ValueKey(note.id),
      index: index,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: NoteCard(
          note: note,
          onTap: () {
            context.go("/notes/view/${note.id}");
          },
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
      ),
    );
  }

  Widget _buildFilterAndSortBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sort Dropdown
          DropdownButton<String>(
            value: _currentSortBy,
            hint: const Text('الفرز حسب'),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _currentSortBy = newValue;
                  _loadNotes();
                });
              }
            },
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(
                value: 'date',
                child: Text('التاريخ'),
              ),
              DropdownMenuItem<String>(
                value: 'title',
                child: Text('العنوان'),
              ),
              DropdownMenuItem<String>(
                value: 'pinned',
                child: Text('المثبتة'),
              ),
            ],
          ),
          // Sort Order Toggle
          IconButton(
            icon: Icon(
              _currentSortAscending ? Icons.arrow_upward : Icons.arrow_downward,
            ),
            onPressed: () {
              setState(() {
                _currentSortAscending = !_currentSortAscending;
                _loadNotes();
              });
            },
          ),
          // Filter by Color
          IconButton(
            icon: Icon(Icons.color_lens, color: _currentFilterColor != null ? Color(_currentFilterColor!) : Colors.grey),
            onPressed: () {
              _showColorFilterDialog(context);
            },
          ),
          // Filter by Tag
          IconButton(
            icon: Icon(Icons.tag, color: _currentFilterTag != null ? Theme.of(context).primaryColor : Colors.grey),
            onPressed: () {
              _showTagFilterDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showColorFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تصفية حسب اللون'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _currentFilterColor != null ? Color(_currentFilterColor!) : Colors.white,
              onColorChanged: (color) {
                setState(() {
                  _currentFilterColor = color.value;
                  _loadNotes();
                });
                Navigator.of(context).pop();
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('إزالة التصفية'),
              onPressed: () {
                setState(() {
                  _currentFilterColor = null;
                  _loadNotes();
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showTagFilterDialog(BuildContext context) {
    // In a real app, you'd fetch available tags from your data source
    final allTags = _notes.expand((note) => note.tags ?? []).toSet().toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تصفية حسب العلامة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (allTags.isEmpty) const Text('لا توجد علامات متاحة.'),
                ...allTags.map((tag) => ListTile(
                  title: Text(tag),
                  onTap: () {
                    setState(() {
                      _currentFilterTag = tag;
                      _loadNotes();
                    });
                    Navigator.of(context).pop();
                  },
                )).toList(),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('إزالة التصفية'),
              onPressed: () {
                setState(() {
                  _currentFilterTag = null;
                  _loadNotes();
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

// Dummy BlockPicker for demonstration. In a real app, use a proper color picker library.
class BlockPicker extends StatelessWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  const BlockPicker({
    Key? key,
    required this.pickerColor,
    required this.onColorChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: <Color>[
            Colors.red,
            Colors.pink,
            Colors.purple,
            Colors.deepPurple,
            Colors.indigo,
            Colors.blue,
            Colors.lightBlue,
            Colors.cyan,
            Colors.teal,
            Colors.green,
            Colors.lightGreen,
            Colors.lime,
            Colors.yellow,
            Colors.amber,
            Colors.orange,
            Colors.deepOrange,
            Colors.brown,
            Colors.grey,
            Colors.blueGrey,
            Colors.black,
            Colors.white,
          ].map((color) => GestureDetector(
            onTap: () => onColorChanged(color),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: pickerColor == color ? Colors.black : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }
}


