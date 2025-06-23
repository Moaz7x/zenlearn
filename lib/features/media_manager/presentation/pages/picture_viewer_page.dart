import 'package:flutter/material.dart';
import 'package:zenlearn/core/widgets/custom_text.dart';

class PictureViewerPage extends StatelessWidget {
  final String? assetPath;
  const PictureViewerPage({this.assetPath, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CustomText(text: 'Picture Viewer Page - Path: ${assetPath ?? "Unknown"}'),
      ),
    );
  }
}
