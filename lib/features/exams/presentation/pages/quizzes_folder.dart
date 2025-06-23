import 'package:flutter/material.dart';
import 'package:zenlearn/core/widgets/app_scaffold.dart';
import 'package:zenlearn/core/widgets/custom_text.dart';

class QuizzesFolderPage extends StatelessWidget {
  const QuizzesFolderPage({super.key, this.folderId});
  final String? folderId;

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      body: Center(
        child: CustomText(text: 'QuizzesFolderPage Page'),
      ),
    );
  }
}
