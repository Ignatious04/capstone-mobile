import 'package:capstone/core/shared/widgets/text/deprecated/text_title_medium.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 56,
      title: const TextTitleMedium(
        title: "Back",
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
