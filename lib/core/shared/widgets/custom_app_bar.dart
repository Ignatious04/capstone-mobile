import 'package:capstone/core/shared/widgets/text/screen_title_text.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 56,
      title: ScreenTitleText(
        value: value,
        color: Colors.white,
      ),
      titleSpacing: 0,
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
