import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_events.dart';
import 'color_picker_widget.dart';

/// A reusable filter bar widget for notes with sorting and filtering options
class NotesFilterBar extends StatelessWidget {
  final String? currentSortBy;
  final bool currentSortAscending;
  final int? currentFilterColor;
  final String? currentFilterTag;
  final List<String> availableTags;
  final VoidCallback? onRefresh;

  const NotesFilterBar({
    super.key,
    this.currentSortBy,
    this.currentSortAscending = true,
    this.currentFilterColor,
    this.currentFilterTag,
    this.availableTags = const [],
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sort Dropdown
          Expanded(
            flex: 2,
            child: _SortDropdown(
              currentSortBy: currentSortBy,
              onSortChanged: (sortBy) {
                context.read<NotesBloc>().add(SortNotesEvent(
                  sortBy: sortBy,
                  ascending: currentSortAscending,
                ));
              },
            ),
          ),
          const SizedBox(width: 8),
          
          // Sort Order Toggle
          _SortOrderButton(
            ascending: currentSortAscending,
            onToggle: () {
              if (currentSortBy != null) {
                context.read<NotesBloc>().add(SortNotesEvent(
                  sortBy: currentSortBy!,
                  ascending: !currentSortAscending,
                ));
              }
            },
          ),
          const SizedBox(width: 8),
          
          // Color Filter Button
          _ColorFilterButton(
            currentFilterColor: currentFilterColor,
            onColorFilterTap: () => _showColorFilterDialog(context),
          ),
          const SizedBox(width: 8),
          
          // Tag Filter Button
          _TagFilterButton(
            currentFilterTag: currentFilterTag,
            onTagFilterTap: () => _showTagFilterDialog(context),
          ),
          const SizedBox(width: 8),
          
          // Refresh Button
          if (onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: onRefresh,
              tooltip: 'تحديث',
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
          content: ColorPickerWidget(
            selectedColor: currentFilterColor,
            onColorSelected: (color) {
              context.read<NotesBloc>().add(FilterNotesByColorEvent(color: color));
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              child: const Text('إزالة التصفية'),
              onPressed: () {
                context.read<NotesBloc>().add(const ClearColorFilterEvent());
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showTagFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تصفية حسب العلامة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (availableTags.isEmpty) 
                  const Text('لا توجد علامات متاحة.'),
                ...availableTags.map((tag) => ListTile(
                  title: Text(tag),
                  selected: currentFilterTag == tag,
                  onTap: () {
                    context.read<NotesBloc>().add(FilterNotesByTagEvent(tag: tag));
                    Navigator.of(context).pop();
                  },
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('إزالة التصفية'),
              onPressed: () {
                context.read<NotesBloc>().add(const ClearTagFilterEvent());
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}

/// Private widget for sort dropdown
class _SortDropdown extends StatelessWidget {
  final String? currentSortBy;
  final ValueChanged<String> onSortChanged;

  const _SortDropdown({
    required this.currentSortBy,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: currentSortBy,
      hint: const Text('الفرز حسب'),
      isExpanded: true,
      onChanged: (String? newValue) {
        if (newValue != null) {
          onSortChanged(newValue);
        }
      },
      items: const [
        DropdownMenuItem(value: 'date', child: Text('التاريخ')),
        DropdownMenuItem(value: 'title', child: Text('العنوان')),
        DropdownMenuItem(value: 'pinned', child: Text('المثبتة')),
      ],
    );
  }
}

/// Private widget for sort order button
class _SortOrderButton extends StatelessWidget {
  final bool ascending;
  final VoidCallback onToggle;

  const _SortOrderButton({
    required this.ascending,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward),
      onPressed: onToggle,
      tooltip: ascending ? 'تصاعدي' : 'تنازلي',
    );
  }
}

/// Private widget for color filter button
class _ColorFilterButton extends StatelessWidget {
  final int? currentFilterColor;
  final VoidCallback onColorFilterTap;

  const _ColorFilterButton({
    required this.currentFilterColor,
    required this.onColorFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.color_lens,
        color: currentFilterColor != null 
            ? Color(currentFilterColor!) 
            : Colors.grey,
      ),
      onPressed: onColorFilterTap,
      tooltip: 'تصفية حسب اللون',
    );
  }
}

/// Private widget for tag filter button
class _TagFilterButton extends StatelessWidget {
  final String? currentFilterTag;
  final VoidCallback onTagFilterTap;

  const _TagFilterButton({
    required this.currentFilterTag,
    required this.onTagFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.tag,
        color: currentFilterTag != null 
            ? Theme.of(context).primaryColor 
            : Colors.grey,
      ),
      onPressed: onTagFilterTap,
      tooltip: 'تصفية حسب العلامة',
    );
  }
}
