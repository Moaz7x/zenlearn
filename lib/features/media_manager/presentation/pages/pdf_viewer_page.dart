import 'package:flutter/material.dart';
import 'package:zenlearn/core/widgets/custom_text.dart';

class PdfViewerPage extends StatelessWidget {
  const PdfViewerPage({required this.assetPath, super.key});
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CustomText(text: 'PDF Viewer Page - Path: $assetPath'),
      ),
    );
  }
}