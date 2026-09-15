import 'package:flutter/material.dart';
import 'package:capstone/core/shared/widgets/text/paragraph_text.dart';
import 'package:capstone/core/shared/widgets/text/supporting_info_text.dart';

Future<bool?> showConfirmationDialog(
  BuildContext context, {
  required String title,
  String? content,
  String cancelText = 'No',
  String confirmText = 'Yes',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return ConfirmationDialog(
        title: title,
        content: content,
        cancelText: cancelText,
        confirmText: confirmText,
      );
    },
  );
}

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    this.content,
    this.cancelText = 'No',
    this.confirmText = 'Yes',
  });

  final String title;
  final String? content;
  final String cancelText;
  final String confirmText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: SupportingInfoText(
        value: title,
      ),
      content: content != null
          ? ParagraphText(
              value: content!,
            )
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
