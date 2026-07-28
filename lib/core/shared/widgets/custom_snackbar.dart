import 'package:capstone/core/shared/widgets/text/text_body_small.dart';
import 'package:flutter/material.dart';

class CustomSnackbar extends SnackBar {
  CustomSnackbar({
    super.key,
    required String text,
  }) : super(
         backgroundColor: Colors.deepOrange,
         behavior: SnackBarBehavior.floating,
         showCloseIcon: true,
         content: TextBodySmall(
           title: text,
           color: Colors.white,
         ),
       );
}
