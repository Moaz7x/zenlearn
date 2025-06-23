import 'package:flutter/material.dart';
import 'package:zenlearn/core/widgets/app_scaffold.dart';
import 'package:zenlearn/core/widgets/custom_text.dart';

class AddQuestionsPage extends StatelessWidget {
  const AddQuestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      body: Center(
        child: CustomText(text: 'Add Questions Page'),
      ),
    );
  }
}
