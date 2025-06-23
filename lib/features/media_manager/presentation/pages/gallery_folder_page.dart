import 'package:flutter/material.dart';
import 'package:zenlearn/core/widgets/custom_text.dart';

class GalleryFolderPage extends StatelessWidget {
  final String? folderId;
  const GalleryFolderPage({this.folderId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CustomText(text: 'Gallery Folder Page - ID: ${folderId ?? "Unknown"}'),
      ),
    );
  }
}
