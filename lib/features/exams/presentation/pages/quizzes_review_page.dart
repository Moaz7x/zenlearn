import 'package:flutter/material.dart';
import 'package:zenlearn/core/widgets/app_scaffold.dart';
import 'package:zenlearn/core/widgets/custom_text.dart';

class QuizzesReviewPage extends StatelessWidget {
  final String? quizId;
  const QuizzesReviewPage({super.key, this.quizId});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      body: Center(
        child: CustomText(text: 'QuizzesReveiew Page'),
      ),
    );
  }
}
