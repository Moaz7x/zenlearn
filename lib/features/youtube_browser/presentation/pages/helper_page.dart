import 'package:flutter/material.dart';
import 'package:zenlearn/core/widgets/app_scaffold.dart';
import 'package:zenlearn/core/widgets/custom_bottom_navigationbar.dart';
import 'package:zenlearn/features/youtube_browser/presentation/pages/youtube_download_page.dart';
import 'package:zenlearn/features/youtube_browser/presentation/pages/youtube_to_transcript_page.dart';

class HelperPage extends StatelessWidget {
  const HelperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'helper Download Page',
      body: AwesomeBottomNavBar(items: const [
        BottomNavItem(icon: Icons.youtube_searched_for, label: 'Youtube donload'),
        BottomNavItem(icon: Icons.code_sharp, label: 'Youtube Trascript'),
      ], pages: const [
        YoutubeDownloadPage(),
        YoutubeToTranscriptPage()
      ]),
    );
  }
}
