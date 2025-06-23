// lib/features/todo/presentation/pages/edit_todo_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zenlearn/core/utils/snackbar_utils.dart';

import '../../domain/entities/todo_entity.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_state.dart';
import '../utils/edit_todo_page_utils.dart';
import '../widgets/edit_todo_page_basic_info_card.dart';
import '../widgets/edit_todo_page_status_card.dart';

class EditTodoPage extends StatefulWidget {
  final TodoEntity? todo;
  const EditTodoPage({super.key, this.todo});

  @override
  State<EditTodoPage> createState() => _EditTodoPageState();
}

class _EditTodoPageState extends State<EditTodoPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  // DateTime? _selectedDate;
  bool _isCompleted = false;
  int? priority;

  bool get isEditing => widget.todo?.id != null ? true : false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Todo' : 'Add New Todo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => saveTodo(
              context: context,
              descriptionController: _descriptionController,
              isCompleted: _isCompleted,
              isEditing: isEditing,
              priority: getPriority,
              selectedDate: getSelectedDate,
              titleController: _titleController,
              todo: widget.todo,
            ),
          ),
        ],
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new)),
      ),
      body: BlocListener<TodoBloc, TodoState>(
        listener: (context, state) {
          if (state is TodoError) {
            context.showGlassSnackBar(
              message: state.message,
            );
          } else if (state is TodoOperationSuccess) {
            context.showGlassSnackBar(
              message: state.message,
            );
            Navigator.pop(context);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EditTodoPageBasicInfoCard(
                descriptionController: _descriptionController,
                titleController: _titleController,
              ),
              const SizedBox(height: 16),
              EditTodoPageStatusCard(
                isCompleted: _isCompleted,
                isEditing: isEditing,
                priority: priority,
                titleController: _titleController,
                descriptionController: _descriptionController,
                selectedDate: getSelectedDate,
                todo: widget.todo,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.access_time, 'Created',
                          formatDate(widget.todo?.createdAt ?? DateTime.now())),
                      if (widget.todo?.subtodos.isNotEmpty ?? false) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.assignment,
                          'Subtasks',
                          '${widget.todo!.subtodos.where((s) => s.isCompleted).length}/${widget.todo!.subtodos.length} completed',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => saveTodo(
                    context: context,
                    descriptionController: _descriptionController,
                    isCompleted: _isCompleted,
                    isEditing: isEditing,
                    priority: getPriority,
                    selectedDate: getSelectedDate,
                    titleController: _titleController,
                    todo: widget.todo,
                  ),
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => showDeleteDialog(context: context, todo: widget.todo),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Delete Todo', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
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
    _descriptionController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String formatPriority(int priority) {
    switch (priority) {
      case 1:
        return 'Low';
      case 2:
        return 'Mid';
      case 3:
        return 'High';
      default:
        return 'Low';
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController = TextEditingController(text: widget.todo?.description ?? '');
    // _selectedDate = widget.todo?.dueDate ?? DateTime.now();
    priority = widget.todo?.priority ?? 1;
    _isCompleted = widget.todo?.isCompleted ?? false;
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}
