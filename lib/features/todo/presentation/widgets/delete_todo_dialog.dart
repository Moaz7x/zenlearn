import 'package:flutter/material.dart';
import 'package:zenlearn/core/localization/app_localizations.dart'; // Assuming this path

/// Shows a confirmation dialog for deleting a Todo item.
///
/// [context]: The BuildContext to show the dialog.
/// [todoId]: The ID of the Todo item to be deleted. (Not directly used in this dialog, but good for context if needed elsewhere)
/// [todoTitle]: The title of the Todo item to be deleted, used in the message.
/// [onDeleteConfirmed]: A callback function to be executed when the user confirms the deletion.
void showDeleteTodoDialog(
  BuildContext context,
  int todoId, // Kept for consistency, though not directly used in this dialog's UI
  String todoTitle,
  VoidCallback onDeleteConfirmed,
) {
  final localizations = AppLocalizations.of(context);

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(localizations.translate('delete_todo_title')),
        content: Text(
          localizations.translate('delete_todo_confirmation_message')
              .replaceFirst('{todoTitle}', todoTitle),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Dismiss the dialog
            },
            child: Text(localizations.translate('cancel')),
          ),
          FilledButton( // Using FilledButton for primary action
            onPressed: () {
              onDeleteConfirmed(); // Execute the delete action
              Navigator.of(dialogContext).pop(); // Dismiss the dialog
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(localizations.translate('delete')),
          ),
        ],
      );
    },
  );
}
