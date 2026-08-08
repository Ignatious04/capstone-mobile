import 'package:capstone/core/shared/widgets/text/deprecated/text_body_small.dart';
import 'package:flutter/material.dart';

class CustomSnackbar extends SnackBar {
  CustomSnackbar({
    super.key,
    required String text,
    Color? color,
  }) : super(
         backgroundColor: Colors.deepOrange,
         behavior: SnackBarBehavior.floating,
         showCloseIcon: true,
         content: TextBodySmall(
           title: text,
           color: color ?? Colors.white,
           isBold: false,
         ),
       );
}
