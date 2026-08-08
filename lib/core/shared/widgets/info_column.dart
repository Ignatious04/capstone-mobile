import 'package:capstone/core/shared/widgets/text/data_label_text.dart';
import 'package:capstone/core/shared/widgets/text/data_value_text.dart';
import 'package:flutter/material.dart';

class InfoColumn extends StatelessWidget {
  const InfoColumn({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DataLabelText(
          value: title,
        ),
        DataValueText(
          value: value,
          isBold: false,
        ),
      ],
    );
  }
}
