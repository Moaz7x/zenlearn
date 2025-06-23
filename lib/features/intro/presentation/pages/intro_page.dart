import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:zenlearn/core/widgets/app_scaffold.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(body: PdfViewer.openFile('assets/pdf/1.pdf'), title: 'Intro Page');
  }
}
