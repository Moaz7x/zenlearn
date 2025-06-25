import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
// REMOVED: import 'package:zenlearn/features/notes/presentation/widgets/note_input_field.dart';
// NEW: Import CustomInput from core widgets
import 'package:zenlearn/core/widgets/custom_input.dart'; // Adjust path if different
import 'package:zenlearn/features/notes/domain/entities/note_entity.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_events.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_states.dart';
// Import custom widgets
import 'package:zenlearn/features/notes/presentation/widgets/color_picker_widget.dart';

class AddNotesPage extends StatefulWidget {
  final NoteEntity? existingNote; // Optional: for editing existing notes

  const AddNotesPage({super.key, this.existingNote});

  @override
  State<AddNotesPage> createState() => _AddNotesPageState();
}

class _AddNotesPageState extends State<AddNotesPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  int? _selectedColor; // To store the selected color

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingNote == null ? 'إضافة ملاحظة جديدة' : 'تعديل ملاحظة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: BlocListener<NotesBloc, NotesState>(
        listener: (context, state) {
          if (state is NoteCreatedSuccess || state is NoteUpdatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(widget.existingNote == null
                      ? 'تم حفظ الملاحظة بنجاح!'
                      : 'تم تحديث الملاحظة بنجاح!')),
            );
            context.pop(); // Go back using GoRouter
          } else if (state is NotesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('خطأ في الحفظ: ${state.failure.message ?? "حدث خطأ غير معروف"}')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Using CustomInput for title
              CustomInput(
                controller: _titleController,
                hintText: 'العنوان',
                maxLines: null, // Allow multiple lines for title if needed
                // CustomInput does not directly expose TextStyle for the TextField,
                // so styling like fontSize: 24, fontWeight: FontWeight.bold
                // might need to be applied by modifying CustomInput itself or
                // by wrapping it with a DefaultTextStyle.
                // For now, it will use CustomInput's default text style.
              ),
              const SizedBox(height: 16),
              Expanded(
                // Using CustomInput for content
                child: CustomInput(
                  controller: _contentController,
                  hintText: 'اكتب ملاحظتك هنا...',
                  maxLines: null, // Allow unlimited lines
                  minLines: 1, // Start with at least one line
                  // CustomInput does not directly expose TextStyle for the TextField.
                ),
              ),
              const SizedBox(height: 16),
              ColorPickerWidget(
                // Using the new ColorPickerWidget
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
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingNote != null) {
      _titleController.text = widget.existingNote!.title;
      _contentController.text = widget.existingNote!.content;
      _selectedColor = widget.existingNote!.color;
    }
  }

  void _saveNote() {
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن حفظ ملاحظة فارغة.')),
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
