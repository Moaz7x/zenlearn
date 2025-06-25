import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:zenlearn/core/widgets/custom_input.dart'; // Make sure this path is correct
import 'package:zenlearn/features/notes/domain/entities/note_entity.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_events.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_states.dart';
import 'package:zenlearn/features/notes/presentation/widgets/color_picker_widget.dart';

class AddNotesPage extends StatefulWidget {
  final NoteEntity? existingNote; // Optional: for editing existing notes

  const AddNotesPage({super.key, this.existingNote});

  @override
  State<AddNotesPage> createState() => _AddNotesPageState();
}

class _AddNotesPageState extends State<AddNotesPage> with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  int? _selectedColor; // To store the selected color

  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.existingNote == null ? 'إضافة ملاحظة جديدة' : 'تعديل ملاحظة'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: _saveNote,
              icon: const Icon(Icons.save, size: 18),
              label: const Text('حفظ'),
              style: ElevatedButton.styleFrom(
                elevation: 4.0, // Added subtle elevation
                shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocListener<NotesBloc, NotesState>(
        listener: (context, state) {
          if (state is NoteCreatedSuccess || state is NoteUpdatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(widget.existingNote == null
                        ? 'تم حفظ الملاحظة بنجاح!'
                        : 'تم تحديث الملاحظة بنجاح!'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
            context.pop(); // Go back using GoRouter
          } else if (state is NotesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('خطأ في الحفظ: ${state.failure.message ?? "حدث خطأ غير معروف"}'),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Title input with enhanced styling
                  CustomInput(
                    controller: _titleController,
                    hintText: 'عنوان الملاحظة',
                    maxLines: null,
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    borderRadius: 16.0,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16), // Adjusted padding
                  ),
                  const SizedBox(height: 20),

                  // Content input with enhanced styling
                  Expanded(
                    child: CustomInput(
                      controller: _contentController,
                      hintText: 'اكتب ملاحظتك هنا...',
                      maxLines: null,
                      minLines: 1,
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      borderRadius: 16.0,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16), // Adjusted padding
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Color picker with enhanced styling
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Material(
                      // Wrap with Material for elevation
                      key: ValueKey(_selectedColor),
                      elevation: 4.0, // Added elevation
                      shadowColor: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.palette,
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'لون الملاحظة',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ColorPickerWidget(
                              selectedColor: _selectedColor,
                              onColorSelected: (color) {
                                setState(() {
                                  _selectedColor = color;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOut,
    ));

    if (widget.existingNote != null) {
      _titleController.text = widget.existingNote!.title;
      _contentController.text = widget.existingNote!.content;
      _selectedColor = widget.existingNote!.color;
    }

    // Start animations
    Future.delayed(const Duration(milliseconds: 100), () {
      _slideAnimationController.forward();
      _fadeAnimationController.forward();
    });
  }

  void _saveNote() {
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('لا يمكن حفظ ملاحظة فارغة.'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (widget.existingNote == null) {
      // Create new note
      final newNote = NoteEntity(
        id: const Uuid().v4(), // Generate a unique ID for the new note
        title: title,
        content: content,
        createdAt: DateTime.now(),
        isPinned: false,
        color: _selectedColor,
      );
      context.read<NotesBloc>().add(CreateNoteEvent(note: newNote));
    } else {
      // Update existing note
      final updatedNote = widget.existingNote!.copyWith(
        title: title,
        content: content,
        updatedAt: DateTime.now(),
        color: _selectedColor,
      );
      context.read<NotesBloc>().add(UpdateNoteEvent(note: updatedNote));
    }
  }
}
