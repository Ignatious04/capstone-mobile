import 'package:capstone/core/shared/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';

class CustomSnackbarHelper {
  static void show(
    BuildContext context, {
    required String text,
    Color? color,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        CustomSnackbar(text: text, color: color,),
      );
  }
}
