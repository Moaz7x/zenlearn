import 'package:flutter/material.dart';
import 'package:zenlearn/core/widgets/custom_text.dart';

import '../routes/app_routes.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool showDrawer;
  const AppScaffold({
    super.key,
    required this.body,
    this.title = 'add title please ',
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.showDrawer = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: title,
          ballColor: Colors.transparent,
          letterDelay: const Duration(milliseconds: 200),
        ),
        actions: actions,
      ),
      drawer: showDrawer ? const CustomDrawer() : const Drawer(),
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
