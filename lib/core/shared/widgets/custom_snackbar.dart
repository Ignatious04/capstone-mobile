import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class CustomSnackbar extends SnackBar {
  CustomSnackbar({
    super.key,
    required String text,
    Color? color,
  }) : super(
         backgroundColor: AppColors.themeColor,
         behavior: SnackBarBehavior.floating,
         showCloseIcon: true,
         content: BodyText(
           value: text,
           color: color ?? AppColors.whiteTextFull,
         ),
       );
}
