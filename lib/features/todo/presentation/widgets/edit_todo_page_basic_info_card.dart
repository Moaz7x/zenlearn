import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_input.dart';

class EditTodoPageBasicInfoCard extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  const EditTodoPageBasicInfoCard({super.key, required this.titleController, required this.descriptionController});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CustomInput(
              controller: titleController,
              hintText: 'Title *',
              borderRadius: 10,
            ),
            const SizedBox(height: 16),
            CustomInput(
              controller: descriptionController,
              hintText: 'Description *',
              borderRadius: 10,
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }
}
