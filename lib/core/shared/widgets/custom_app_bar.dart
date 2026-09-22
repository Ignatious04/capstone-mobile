import 'package:capstone/core/shared/widgets/text/screen_title_text.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 3,
      scrolledUnderElevation: 3,
      shadowColor: Colors.black54,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 60,
      title: ScreenTitleText(
        value: value,
        color: Colors.white,
        isBold: true,
      ),
      titleSpacing: 0,
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
