import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart'; // NEW: Import go_router
import 'package:zenlearn/features/notes/domain/entities/note_entity.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_events.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_states.dart';

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
  void initState() {
    super.initState();
    if (widget.existingNote != null) {
      _titleController.text = widget.existingNote!.title;
      _contentController.text = widget.existingNote!.content;
      _selectedColor = widget.existingNote!.color;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
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
              SnackBar(content: Text(widget.existingNote == null ? 'تم حفظ الملاحظة بنجاح!' : 'تم تحديث الملاحظة بنجاح!')),
            );
            context.pop(); // Go back using GoRouter
          } else if (state is NotesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('خطأ في الحفظ: ${state.failure.message ?? "حدث خطأ غير معروف"}')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'العنوان',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                maxLines: null,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: 'اكتب ملاحظتك هنا...',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
              ),
              // Placeholder for color picker
              Wrap(
                spacing: 8.0,
                children: [
                  _buildColorOption(Colors.red),
                  _buildColorOption(Colors.blue),
                  _buildColorOption(Colors.green),
                  _buildColorOption(Colors.yellow),
                  _buildColorOption(Colors.purple),
                  _buildColorOption(Colors.grey),
                  _buildColorOption(Colors.transparent), // For no color
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color) {
    final int colorValue = color.value;
    final bool isSelected = _selectedColor == colorValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = isSelected && color == Colors.transparent ? null : colorValue;
        });
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
        child: color == Colors.transparent
            ? Center(
                child: Icon(
                  Icons.close,
                  color: isSelected ? Colors.black : Colors.grey,
                  size: 20,
                ),
              )
            : null,
      ),
    );
  }
}
