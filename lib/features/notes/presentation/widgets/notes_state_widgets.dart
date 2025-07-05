import 'package:flutter/material.dart';

import '../../../../core/errors/failures.dart';
import 'skeleton_loading_widget.dart';

/// A widget for displaying empty states in the notes feature
class NotesEmptyWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;
  final Widget? customAction;

  const NotesEmptyWidget({
    super.key,
    this.title = 'لا توجد ملاحظات',
    this.subtitle = 'ابدأ بإضافة ملاحظة جديدة',
    this.icon = Icons.note_add_outlined,
    this.onAction,
    this.actionText,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (customAction != null)
              customAction!
            else if (onAction != null)
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText ?? 'إضافة ملاحظة'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A widget for displaying error states in the notes feature
class NotesErrorWidget extends StatelessWidget {
  final Failure? failure;
  final VoidCallback? onRetry;
  final String? customMessage;

  const NotesErrorWidget({
    super.key,
    this.failure,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getErrorIcon(),
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              _getErrorTitle(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              customMessage ?? _getErrorMessage(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon() {
    if (failure == null) return Icons.error_outline;

    if (failure is DatabaseFailure) {
      return Icons.storage_outlined;
    } else if (failure is NetworkFailure) {
      return Icons.wifi_off_outlined;
    } else if (failure is NotFoundFailure) {
      return Icons.search_off_outlined;
    } else {
      return Icons.error_outline;
    }
  }

  String _getErrorMessage() {
    if (failure == null) {
      return customMessage ?? 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
    }

    if (failure is DatabaseFailure) {
      return 'حدث خطأ أثناء الوصول إلى قاعدة البيانات. يرجى المحاولة مرة أخرى.';
    } else if (failure is NetworkFailure) {
      return 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى.';
    } else if (failure is NotFoundFailure) {
      final notFoundFailure = failure as NotFoundFailure;
      return notFoundFailure.message ?? 'لم يتم العثور على البيانات المطلوبة.';
    } else {
      return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
    }
  }

  String _getErrorTitle() {
    if (failure == null) return 'حدث خطأ';

    if (failure is DatabaseFailure) {
      return 'خطأ في قاعدة البيانات';
    } else if (failure is NetworkFailure) {
      return 'خطأ في الاتصال';
    } else if (failure is NotFoundFailure) {
      return 'لم يتم العثور على البيانات';
    } else {
      return 'حدث خطأ';
    }
  }
}

/// A widget for displaying filter-specific empty states
class NotesFilterEmptyWidget extends StatelessWidget {
  final String filterType;
  final String filterValue;
  final VoidCallback? onClearFilter;

  const NotesFilterEmptyWidget({
    super.key,
    required this.filterType,
    required this.filterValue,
    this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد ملاحظات',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'لا توجد ملاحظات تطابق $filterType "$filterValue"',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (onClearFilter != null)
              OutlinedButton.icon(
                onPressed: onClearFilter,
                icon: const Icon(Icons.clear),
                label: const Text('إزالة التصفية'),
              ),
          ],
        ),
      ),
    );
  }
}

/// A widget for displaying loading states in the notes feature
class NotesLoadingWidget extends StatelessWidget {
  final String? message;
  final bool showProgress;
  final double? progress;
  final bool useSkeleton;
  final int skeletonItemCount;

  const NotesLoadingWidget({
    super.key,
    this.message,
    this.showProgress = false,
    this.progress,
    this.useSkeleton = true,
    this.skeletonItemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    if (useSkeleton) {
      return Column(
        children: [
          if (message != null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                message!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          Expanded(
            child: SkeletonLoadingWidget(
              itemCount: skeletonItemCount,
            ),
          ),
        ],
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showProgress && progress != null)
            CircularProgressIndicator(value: progress)
          else
            const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// A widget for displaying search-specific empty states
class NotesSearchEmptyWidget extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClearSearch;

  const NotesSearchEmptyWidget({
    super.key,
    required this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد نتائج',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                children: [
                  const TextSpan(text: 'لم يتم العثور على ملاحظات تحتوي على '),
                  TextSpan(
                    text: '"$searchQuery"',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (onClearSearch != null)
              OutlinedButton.icon(
                onPressed: onClearSearch,
                icon: const Icon(Icons.clear),
                label: const Text('مسح البحث'),
              ),
          ],
        ),
      ),
    );
  }
}
