import 'package:flutter/material.dart';

class TextCheatSheet extends StatelessWidget {
  const TextCheatSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "",
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(),
        ),
        Text(
          "",
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(),
        ),
        Text(
          "",
          style: Theme.of(
            context,
          ).textTheme.displaySmall?.copyWith(),
        ),
        Text(
          "",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(),
        ),
        Text(
          "",
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(),
        ),
      ],
    );
  }
}
