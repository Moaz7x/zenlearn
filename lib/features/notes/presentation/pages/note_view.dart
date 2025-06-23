import 'package:flutter/material.dart';
import 'package:zenlearn/core/widgets/custom_text.dart';

class NoteViewPage extends StatelessWidget {
  final String? noteId;
  const NoteViewPage({this.noteId, super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CustomText(text: 'Note View Page'),
      ),
    );
  }
}
