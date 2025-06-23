import 'package:flutter/material.dart';
import 'package:zenlearn/core/widgets/custom_text.dart';

class AddNotesPage extends StatelessWidget {
  const AddNotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CustomText(text: 'Add notes Page'),
      ),
    );
  }
}
