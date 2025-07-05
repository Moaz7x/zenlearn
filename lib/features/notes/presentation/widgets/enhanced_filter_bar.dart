import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/notes_bloc.dart';
import '../bloc/notes_events.dart';
import 'color_picker_widget.dart';

/// Enhanced filter bar with collapsible sections and visual indicators
class EnhancedFilterBar extends StatefulWidget {
  final String? currentSortBy;
  final bool currentSortAscending;
  final int? currentFilterColor;
  final String? currentFilterTag;
  final List<String> availableTags;
  final int totalNotesCount;
  final int filteredNotesCount;
  final VoidCallback? onRefresh;
  final Animation<double>? slideAnimation;

  const EnhancedFilterBar({
    super.key,
    this.currentSortBy,
    this.currentSortAscending = true,
    this.currentFilterColor,
    this.currentFilterTag,
    this.availableTags = const [],
    this.totalNotesCount = 0,
    this.filteredNotesCount = 0,
    this.onRefresh,
    this.slideAnimation,
  });

  @override
  State<EnhancedFilterBar> createState() => _EnhancedFilterBarState();
}

class _EnhancedFilterBarState extends State<EnhancedFilterBar>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  bool get _hasActiveFilters {
    return widget.currentFilterColor != null || 
           widget.currentFilterTag != null ||
           widget.currentSortBy != null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          // Main filter bar
          _buildMainFilterBar(),
          
          // Expandable filter section
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: _buildExpandedFilters(),
          ),
          
          // Filter results indicator
          if (_hasActiveFilters) _buildFilterResultsIndicator(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorFilterChip() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Color(widget.currentFilterColor!),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'لون',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => context.read<NotesBloc>().add(const ClearColorFilterEvent()),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تصفية حسب اللون',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ColorPickerWidget(
          selectedColor: widget.currentFilterColor,
          onColorSelected: (color) {
            context.read<NotesBloc>().add(FilterNotesByColorEvent(color: color));
          },
        ),
      ],
    );
  }

  // Widget _buildCompactColorPicker() {
  //   const colors = [
  //     Colors.red,
  //     Colors.blue,
  //     Colors.green,
  //     Colors.orange,
  //     Colors.purple,
  //     Colors.teal,
  //   ];

  //   return Row(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       // Clear option
  //       GestureDetector(
  //         onTap: () => context.read<NotesBloc>().add(const ClearColorFilterEvent()),
  //         child: Container(
  //           width: 24,
  //           height: 24,
  //           decoration: BoxDecoration(
  //             shape: BoxShape.circle,
  //             border: Border.all(
  //               color: widget.currentFilterColor == null ? Colors.black : Colors.grey,
  //               width: widget.currentFilterColor == null ? 2 : 1,
  //             ),
  //             color: Colors.white,
  //           ),
  //           child: widget.currentFilterColor == null
  //               ? const Icon(Icons.check, color: Colors.black, size: 16)
  //               : Icon(Icons.clear, color: Colors.grey[400], size: 16),
  //         ),
  //       ),
  //       const SizedBox(width: 8),

  //       // Color options
  //       ...colors.map((color) => Padding(
  //         padding: const EdgeInsets.only(right: 8),
  //         child: GestureDetector(
  //           onTap: () => context.read<NotesBloc>().add(FilterNotesByColorEvent(color: color.value)),
  //           child: Container(
  //             width: 24,
  //             height: 24,
  //             decoration: BoxDecoration(
  //               color: color,
  //               shape: BoxShape.circle,
  //               border: Border.all(
  //                 color: widget.currentFilterColor == color.value ? Colors.black : Colors.grey,
  //                 width: widget.currentFilterColor == color.value ? 2 : 1,
  //               ),
  //             ),
  //             child: widget.currentFilterColor == color.value
  //                 ? const Icon(Icons.check, color: Colors.white, size: 16)
  //                 : null,
  //           ),
  //         ),
  //       )),
  //     ],
  //   );
  // }

  Widget _buildExpandedFilters() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sort options
          _buildSortSection(),
          const SizedBox(height: 16),
          
          // Color filter
          _buildColorFilterSection(),
          const SizedBox(height: 16),
          
          // Tag filter
          _buildTagFilterSection(),
        ],
      ),
    );
  }

  Widget _buildFilterResultsIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            size: 16,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'عرض ${widget.filteredNotesCount} من ${widget.totalNotesCount} ملاحظة',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Filter toggle button
          Semantics(
            label: _isExpanded ? 'إخفاء خيارات التصفية' : 'إظهار خيارات التصفية',
            hint: 'اضغط لتوسيع أو طي خيارات التصفية',
            button: true,
            child: IconButton(
              icon: AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.tune,
                  color: _hasActiveFilters
                      ? Theme.of(context).primaryColor
                      : Colors.grey[600],
                  semanticLabel: 'أيقونة التصفية',
                ),
              ),
              onPressed: _toggleExpanded,
              tooltip: 'تصفية الملاحظات',
            ),
          ),
          
          // Active filters chips
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (widget.currentSortBy != null) 
                    _buildActiveFilterChip(
                      'الترتيب: ${_getSortDisplayName(widget.currentSortBy!)}',
                      () => context.read<NotesBloc>().add(const SortNotesEvent(sortBy: null)),
                    ),
                  if (widget.currentFilterColor != null)
                    _buildColorFilterChip(),
                  if (widget.currentFilterTag != null)
                    _buildActiveFilterChip(
                      'العلامة: ${widget.currentFilterTag}',
                      () => context.read<NotesBloc>().add(const ClearTagFilterEvent()),
                    ),
                ],
              ),
            ),
          ),
          
          // Clear all filters
          if (_hasActiveFilters)
            Semantics(
              label: 'مسح جميع المرشحات',
              hint: 'اضغط لإزالة جميع المرشحات المطبقة',
              button: true,
              child: TextButton(
                onPressed: _clearAllFilters,
                child: const Text('مسح الكل'),
              ),
            ),
          
          // Refresh button
          if (widget.onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: widget.onRefresh,
              tooltip: 'تحديث',
            ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String sortBy, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: widget.currentSortBy == sortBy,
      onSelected: (selected) {
        if (selected) {
          context.read<NotesBloc>().add(SortNotesEvent(
            sortBy: sortBy,
            ascending: widget.currentSortAscending,
          ));
        } else {
          context.read<NotesBloc>().add(const SortNotesEvent(sortBy: null));
        }
      },
    );
  }

  Widget _buildSortSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ترتيب الملاحظات',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildSortChip('date', 'التاريخ'),
            _buildSortChip('title', 'العنوان'),
            _buildSortChip('pinned', 'المثبتة'),
          ],
        ),
        if (widget.currentSortBy != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('الاتجاه: '),
              ChoiceChip(
                label: const Text('تصاعدي'),
                selected: widget.currentSortAscending,
                onSelected: (selected) {
                  if (selected && widget.currentSortBy != null) {
                    context.read<NotesBloc>().add(SortNotesEvent(
                      sortBy: widget.currentSortBy!,
                      ascending: true,
                    ));
                  }
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('تنازلي'),
                selected: !widget.currentSortAscending,
                onSelected: (selected) {
                  if (selected && widget.currentSortBy != null) {
                    context.read<NotesBloc>().add(SortNotesEvent(
                      sortBy: widget.currentSortBy!,
                      ascending: false,
                    ));
                  }
                },
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTagFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تصفية حسب العلامة',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.availableTags.isEmpty)
          const Text('لا توجد علامات متاحة')
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.availableTags.map((tag) => FilterChip(
              label: Text(tag),
              selected: widget.currentFilterTag == tag,
              onSelected: (selected) {
                if (selected) {
                  context.read<NotesBloc>().add(FilterNotesByTagEvent(tag: tag));
                } else {
                  context.read<NotesBloc>().add(const ClearTagFilterEvent());
                }
              },
            )).toList(),
          ),
      ],
    );
  }

  void _clearAllFilters() {
    context.read<NotesBloc>().add(const ClearTagFilterEvent());
    context.read<NotesBloc>().add(const ClearColorFilterEvent());
    context.read<NotesBloc>().add(const SortNotesEvent(sortBy: null));
  }

  String _getSortDisplayName(String sortBy) {
    switch (sortBy) {
      case 'date':
        return 'التاريخ';
      case 'title':
        return 'العنوان';
      case 'pinned':
        return 'المثبتة';
      default:
        return sortBy;
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }
}
