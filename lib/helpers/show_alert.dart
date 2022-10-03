import 'package:flutter/material.dart';

void showAlert(String title, String errorMessage, BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(errorMessage),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, 'Ok'),
            child: const Text('Ok'))
      ],
    ),
    barrierDismissible: false,
  );
}
