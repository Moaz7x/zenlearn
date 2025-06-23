import 'package:flutter/material.dart';
import 'package:zenlearn/core/widgets/app_scaffold.dart';
import 'package:zenlearn/core/widgets/custom_text.dart';

class FlashcardsFolderPage extends StatelessWidget {
  const FlashcardsFolderPage({this.folderId, super.key});
  final String? folderId;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: CustomText(text: 'Flashcards Folder Page - ID: ${folderId ?? "Unknown"}'),
      ),
    );
  }
}