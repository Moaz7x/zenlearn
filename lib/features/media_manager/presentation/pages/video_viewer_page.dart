import 'package:flutter/material.dart';
import 'package:zenlearn/core/widgets/custom_text.dart';

class VideoViewerPage extends StatelessWidget {
  const VideoViewerPage({required this.videoPath, required this.title, super.key});
  final String videoPath;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CustomText(text: 'Video Viewer Page - Title: $title, Path: $videoPath'),
      ),
    );
  }
}