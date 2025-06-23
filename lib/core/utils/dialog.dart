import 'package:flutter/material.dart';

import '../widgets/custom_dialog.dart';

void showGlassDialog({
  required BuildContext context,

  GlassDialogType type = GlassDialogType.info,
  required Widget content 
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.3),
    builder: (context) => GlassDialog(
     
      type: type,
      content: content,
    ),
  );
}
