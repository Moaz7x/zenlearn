import 'package:flutter/material.dart';
import 'package:zenlearn/core/widgets/custom_text.dart';
import '../../../../core/widgets/app_scaffold.dart';
class ClassesCalendarPage extends StatelessWidget {
  const ClassesCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      body: Center(
        child: CustomText(text: 'Classes Calendar Page'),
      ),
    );
  }
}