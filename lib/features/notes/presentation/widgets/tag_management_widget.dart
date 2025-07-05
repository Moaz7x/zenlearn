import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/note_entity.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_events.dart';

/// A widget for displaying tags in a read-only format
class ReadOnlyTagsWidget extends StatelessWidget {
  final List<String> tags;
  final WrapAlignment alignment;
  final double spacing;
  final double runSpacing;
  final Color? backgroundColor;
  final Color? textColor;

  const ReadOnlyTagsWidget({
    super.key,
    required this.tags,
    this.alignment = WrapAlignment.start,
    this.spacing = 8.0,
    this.runSpacing = 4.0,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      alignment: alignment,
      spacing: spacing,
      runSpacing: runSpacing,
      children: tags.map((tag) => TagChip(
        tag: tag,
        backgroundColor: backgroundColor,
        textColor: textColor,
      )).toList(),
    );
  }
}

/// A chip widget for displaying individual tags
class TagChip extends StatelessWidget {
  final String tag;
  final VoidCallback? onRemove;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;

  const TagChip({
    super.key,
    required this.tag,
    this.onRemove,
    this.backgroundColor,
    this.textColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        tag,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      deleteIcon: onRemove != null 
          ? Icon(
              Icons.close,
              size: 16,
              color: textColor ?? Colors.white,
            )
          : null,
      onDeleted: onRemove,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

/// A reusable widget for managing tags on notes
class TagManagementWidget extends StatefulWidget {
  final NoteEntity note;
  final bool isReadOnly;
  final bool showAddButton;
  final EdgeInsetsGeometry? padding;
  final WrapAlignment alignment;
  final double spacing;
  final double runSpacing;

  const TagManagementWidget({
    super.key,
    required this.note,
    this.isReadOnly = false,
    this.showAddButton = true,
    this.padding,
    this.alignment = WrapAlignment.start,
    this.spacing = 8.0,
    this.runSpacing = 4.0,
  });

  @override
  State<TagManagementWidget> createState() => _TagManagementWidgetState();
}

/// A widget for selecting tags from a predefined list
class TagSelectorWidget extends StatelessWidget {
  final List<String> availableTags;
  final List<String> selectedTags;
  final ValueChanged<List<String>> onSelectionChanged;
  final bool allowMultipleSelection;

  const TagSelectorWidget({
    super.key,
    required this.availableTags,
    required this.selectedTags,
    required this.onSelectionChanged,
    this.allowMultipleSelection = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: availableTags.map((tag) {
        final isSelected = selectedTags.contains(tag);
        return FilterChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (selected) {
            List<String> newSelection = List.from(selectedTags);
            if (selected) {
              if (allowMultipleSelection) {
                newSelection.add(tag);
              } else {
                newSelection = [tag];
              }
            } else {
              newSelection.remove(tag);
            }
            onSelectionChanged(newSelection);
          },
        );
      }).toList(),
    );
  }
}

/// A button for adding new tags
class _AddTagButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddTagButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, size: 16),
          SizedBox(width: 4),
          Text('إضافة علامة', style: TextStyle(fontSize: 12)),
        ],
      ),
      onPressed: onPressed,
      backgroundColor: Colors.grey[200],
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

/// An inline input field for adding tags
class _InlineTagInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmitted;
  final VoidCallback onCancelled;

  const _InlineTagInput({
    required this.controller,
    required this.onSubmitted,
    required this.onCancelled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'علامة',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 12),
              textDirection: TextDirection.rtl,
              autofocus: true,
              onSubmitted: (_) => onSubmitted(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check, size: 16),
            onPressed: onSubmitted,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: onCancelled,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }
}

class _TagManagementWidgetState extends State<TagManagementWidget> {
  final TextEditingController _tagController = TextEditingController();
  bool _isAddingTag = false;

  @override
  Widget build(BuildContext context) {
    final tags = widget.note.tags ?? [];
    
    return Container(
      padding: widget.padding,
      child: Wrap(
        alignment: widget.alignment,
        spacing: widget.spacing,
        runSpacing: widget.runSpacing,
        children: [
          // Existing tags
          ...tags.map((tag) => TagChip(
            tag: tag,
            onRemove: widget.isReadOnly ? null : () => _removeTag(tag),
          )),
          
          // Add tag button
          if (!widget.isReadOnly && widget.showAddButton)
            _isAddingTag
                ? _InlineTagInput(
                    controller: _tagController,
                    onSubmitted: _addTag,
                    onCancelled: () => setState(() => _isAddingTag = false),
                  )
                : _AddTagButton(
                    onPressed: () => setState(() => _isAddingTag = true),
                  ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !(widget.note.tags?.contains(tag) ?? false)) {
      context.read<NotesBloc>().add(AddTagToNoteEvent(note: widget.note, tag: tag));
      _tagController.clear();
      setState(() {
        _isAddingTag = false;
      });
    }
  }



  void _removeTag(String tag) {
    context.read<NotesBloc>().add(RemoveTagFromNoteEvent(note: widget.note, tag: tag));
  }
}
