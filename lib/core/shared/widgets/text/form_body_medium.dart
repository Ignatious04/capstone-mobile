import 'package:flutter/material.dart';

class FormBodyMedium extends StatelessWidget {
  const FormBodyMedium({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          body,
          style:
              Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
