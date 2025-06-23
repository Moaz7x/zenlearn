import 'package:flutter/material.dart';
import 'package:zenlearn/core/widgets/custom_text.dart';

class YoutubeToTranscriptPage extends StatelessWidget {
  const YoutubeToTranscriptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CustomText(text: 'YouTube to Transcript Page'),
      ),
    );
  }
}
