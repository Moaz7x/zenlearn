import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:zenlearn/features/notes/domain/entities/note_entity.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_events.dart';
import 'package:zenlearn/features/notes/presentation/bloc/notes_states.dart';

import '../widgets/color_picker_widget.dart';
import '../widgets/tag_management_widget.dart';

/// Optimized add/edit notes page with extracted components
class OptimizedAddNotesPage extends StatefulWidget {
  final NoteEntity? existingNote;

  const OptimizedAddNotesPage({super.key, this.existingNote});

  @override
  State<OptimizedAddNotesPage> createState() => _OptimizedAddNotesPageState();
}

class _OptimizedAddNotesPageState extends State<OptimizedAddNotesPage>
    with TickerProviderStateMixin {
  
  // Form controllers
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // Note properties
  int? _selectedColor;
  List<String> _tags = [];
  bool _isEditing = false;
  
  // Animation controllers
  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: BlocListener<NotesBloc, NotesState>(
        listener: (context, state) {
          if (state is NoteCreatedSuccess || state is NoteUpdatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isEditing ? 'تم تحديث الملاحظة' : 'تم إنشاء الملاحظة'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is NotesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('حدث خطأ: ${state.failure}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildForm(),
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
    _initializeAnimations();
    _initializeForm();
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.pop(),
            child: const Text('إلغاء'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveNote,
            child: Text(_isEditing ? 'تحديث الملاحظة' : 'حفظ الملاحظة'),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_isEditing ? 'تعديل الملاحظة' : 'إضافة ملاحظة جديدة'),
      elevation: 0,
      backgroundColor: Colors.transparent,
      actions: [
        TextButton(
          onPressed: _saveNote,
          child: Text(
            _isEditing ? 'تحديث' : 'حفظ',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'لون الملاحظة',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
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
    );
  }

  Widget _buildContentField() {
    return TextFormField(
      controller: _contentController,
      decoration: const InputDecoration(
        labelText: 'محتوى الملاحظة',
        hintText: 'أدخل محتوى الملاحظة',
        border: OutlineInputBorder(),
      ),
      maxLines: 8,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'يرجى إدخال محتوى الملاحظة';
        }
        return null;
      },
      textInputAction: TextInputAction.newline,
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildContentField(),
            const SizedBox(height: 24),
            _buildColorSection(),
            const SizedBox(height: 24),
            _buildTagsSection(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTagInput() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: [
        ..._tags.map((tag) => Chip(
          label: Text(tag),
          onDeleted: () {
            setState(() {
              _tags.remove(tag);
            });
          },
        )),
        ActionChip(
          label: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 16),
              SizedBox(width: 4),
              Text('إضافة علامة'),
            ],
          ),
          onPressed: _showAddTagDialog,
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'العلامات',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (widget.existingNote != null)
          TagManagementWidget(
            note: widget.existingNote!,
            isReadOnly: false,
            showAddButton: true,
          )
        else
          _buildTagInput(),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'عنوان الملاحظة',
        hintText: 'أدخل عنوان الملاحظة',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'يرجى إدخال عنوان الملاحظة';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  void _initializeAnimations() {
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
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
      curve: Curves.easeIn,
    ));

    // Start animations
    _slideAnimationController.forward();
    _fadeAnimationController.forward();
  }

  void _initializeForm() {
    if (widget.existingNote != null) {
      _isEditing = true;
      _titleController.text = widget.existingNote!.title;
      _contentController.text = widget.existingNote!.content;
      _selectedColor = widget.existingNote!.color;
      _tags = List.from(widget.existingNote!.tags ?? []);
    }
  }

  void _saveNote() {
    if (!_formKey.currentState!.validate()) return;

    final note = NoteEntity(
      id: widget.existingNote?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      createdAt: widget.existingNote?.createdAt ?? DateTime.now(),
      updatedAt: _isEditing ? DateTime.now() : null,
      color: _selectedColor,
      tags: _tags.isEmpty ? null : _tags,
      order: widget.existingNote?.order,
    );

    if (_isEditing) {
      context.read<NotesBloc>().add(UpdateNoteEvent(note: note));
    } else {
      context.read<NotesBloc>().add(CreateNoteEvent(note: note));
    }
  }

  void _showAddTagDialog() {
    final tagController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة علامة جديدة'),
        content: TextField(
          controller: tagController,
          decoration: const InputDecoration(
            hintText: 'اسم العلامة',
            border: OutlineInputBorder(),
          ),
          textDirection: TextDirection.rtl,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final tag = tagController.text.trim();
              if (tag.isNotEmpty && !_tags.contains(tag)) {
                setState(() {
                  _tags.add(tag);
                });
              }
              Navigator.of(context).pop();
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
