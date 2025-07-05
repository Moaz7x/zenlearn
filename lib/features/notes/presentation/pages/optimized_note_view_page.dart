import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/note_entity.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_events.dart';
import '../bloc/notes_states.dart';
import '../widgets/notes_state_widgets.dart';
import '../widgets/tag_management_widget.dart';

/// Optimized note view page with extracted components and improved performance
class OptimizedNoteViewPage extends StatefulWidget {
  final String noteId;

  const OptimizedNoteViewPage({super.key, required this.noteId});

  @override
  State<OptimizedNoteViewPage> createState() => _OptimizedNoteViewPageState();
}

class _OptimizedNoteViewPageState extends State<OptimizedNoteViewPage>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  NoteEntity? _currentNote;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: BlocConsumer<NotesBloc, NotesState>(
        listener: (context, state) {
          if (state is NoteLoadedById) {
            setState(() {
              _currentNote = state.note;
            });
          } else if (state is NoteUpdatedSuccess) {
            setState(() {
              _currentNote = state.note;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديث الملاحظة'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is NotesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('حدث خطأ: ${state.failure}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return _buildContent(state);
        },
      ),
    );
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadNote();
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('عرض الملاحظة'),
      elevation: 0,
      backgroundColor: Colors.transparent,
      actions: [
        if (_currentNote != null) ...[
          IconButton(
            icon: Icon(
              _currentNote!.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _currentNote!.isPinned ? Colors.orange : null,
            ),
            onPressed: _togglePin,
            tooltip: _currentNote!.isPinned ? 'إلغاء التثبيت' : 'تثبيت',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/notes/edit/${widget.noteId}', extra: _currentNote),
            tooltip: 'تعديل',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteNote,
            tooltip: 'حذف',
          ),
        ],
      ],
    );
  }

  Widget _buildContent(NotesState state) {
    if (state is NotesLoading) {
      return const NotesLoadingWidget(message: 'جاري تحميل الملاحظة...');
    }
    
    if (state is NotesError) {
      return NotesErrorWidget(
        failure: state.failure,
        onRetry: _loadNote,
      );
    }
    
    if (_currentNote == null) {
      return const NotesErrorWidget(
        failure: null,
        customMessage: 'لم يتم العثور على الملاحظة',
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _buildNoteContent(),
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteBody(NoteEntity note) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Text(
        note.content,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.6,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildNoteContent() {
    final note = _currentNote!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNoteHeader(note),
          const SizedBox(height: 24),
          _buildNoteBody(note),
          const SizedBox(height: 24),
          _buildNoteTags(note),
          const SizedBox(height: 24),
          _buildNoteMetadata(note),
        ],
      ),
    );
  }

  Widget _buildNoteHeader(NoteEntity note) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: note.color != null ? Color(note.color!) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  note.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: note.color != null ? Colors.white : null,
                  ),
                ),
              ),
              if (note.isPinned)
                Icon(
                  Icons.push_pin,
                  color: note.color != null ? Colors.white : Colors.orange,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteMetadata(NoteEntity note) {
    final dateFormat = DateFormat('dd/MM/yyyy - HH:mm');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات الملاحظة',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildMetadataRow('تاريخ الإنشاء', dateFormat.format(note.createdAt)),
          if (note.updatedAt != null)
            _buildMetadataRow('آخر تحديث', dateFormat.format(note.updatedAt!)),
          _buildMetadataRow('عدد الكلمات', '${note.content.split(' ').length}'),
          _buildMetadataRow('عدد الأحرف', '${note.content.length}'),
        ],
      ),
    );
  }

  Widget _buildNoteTags(NoteEntity note) {
    if (note.tags == null || note.tags!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'العلامات',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TagManagementWidget(
          note: note,
          isReadOnly: false,
          showAddButton: true,
        ),
      ],
    );
  }

  void _deleteNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الملاحظة'),
        content: const Text('هل أنت متأكد من حذف هذه الملاحظة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<NotesBloc>().add(DeleteNoteEvent(noteId: widget.noteId));
              Navigator.of(context).pop();
              context.pop(); // Go back to notes list
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeAnimationController.forward();
    _slideAnimationController.forward();
  }

  void _loadNote() {
    context.read<NotesBloc>().add(GetNoteByIdEvent(noteId: widget.noteId));
  }

  void _togglePin() {
    if (_currentNote != null) {
      context.read<NotesBloc>().add(TogglePinNoteEvent(note: _currentNote!));
    }
  }
}
