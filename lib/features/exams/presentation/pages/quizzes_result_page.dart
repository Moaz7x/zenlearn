import 'package:flutter/material.dart';
import 'package:zenlearn/core/widgets/app_scaffold.dart';
import 'package:zenlearn/core/widgets/custom_text.dart';

class QuizzesResultPage extends StatelessWidget {
  const QuizzesResultPage({super.key, this.attemptId});
  final String? attemptId;

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      body: Center(
        child: CustomText(text: 'Quizzes Result Page'),
      ),
    );
  }
}
