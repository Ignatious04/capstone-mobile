import 'package:capstone/core/shared/widgets/text/headline_text.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, required this.value, this.actions});

  final String value;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 3,
      scrolledUnderElevation: 3,
      shadowColor: Colors.black54,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 60,
      title: HeadlineText(
        value: value,
        color: Colors.white,
        isBold: true,
      ),
      titleSpacing: 0,
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
