import 'package:capstone/core/shared/widgets/text/data_label_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDatePickerWidget extends StatelessWidget {
  const CustomDatePickerWidget({
    super.key,
    required this.title,
    required this.controller,
    this.validator,
    this.onChanged,
  });

  final String title;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DataLabelText(value: title),
        SizedBox(
          height: 10,
        ),
        TextField(
          controller: controller,
          readOnly: true,
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            suffixIconConstraints: BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );

            if (date != null) {
              controller.text = DateFormat(
                "MM/dd/yy",
              ).format(date);
            }
          },
          onChanged: onChanged,
        ),
      ],
    );
  }
}
