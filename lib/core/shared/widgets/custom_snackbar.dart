import 'package:capstone/core/shared/widgets/text/supporting_info_text.dart';
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
         content: SupportingInfoText(
           value: text,
           color: color ?? Colors.white,
         ),
       );
}
