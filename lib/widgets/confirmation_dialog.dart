import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String content;

  const ConfirmationDialog({Key? key, required this.content}) : super(key: key);

  static Future<bool?> show(BuildContext context, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(content: content),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      title: const Text('Confirmation'),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text('Yes'),
        ),
      ],
    );
  }
}
