import 'package:flutter/material.dart';
import 'package:zenlearn/core/widgets/app_scaffold.dart';
import 'package:zenlearn/core/widgets/custom_text.dart';

class FlashcardsShuffledReviewPage extends StatelessWidget {
  const FlashcardsShuffledReviewPage({this.setId, super.key});
  final String? setId;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: CustomText(text: 'Flashcards Shuffled Review Page - Set ID: ${setId ?? "Unknown"}'),
      ),
    );
  }
}
