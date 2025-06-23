import 'package:flutter/material.dart';
import 'package:zenlearn/core/widgets/custom_text.dart';

class AudioViewerPage extends StatelessWidget {
  final String? assetPath;
  const AudioViewerPage({this.assetPath, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CustomText(text: 'Audio Viewer Page - Path: ${assetPath ?? "Unknown"}'),
      ),
    );
  }
}
