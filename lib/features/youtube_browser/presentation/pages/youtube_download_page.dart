import 'package:flutter/material.dart';
import 'package:zenlearn/core/widgets/custom_text.dart';

class YoutubeDownloadPage extends StatelessWidget {
  const YoutubeDownloadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CustomText(text: 'YouTube Download Page'),
      ),
    );
  }
}
