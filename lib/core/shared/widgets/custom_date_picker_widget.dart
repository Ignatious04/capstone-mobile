import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:flutter/material.dart';

class CustomDatePickerWidget extends StatelessWidget {
  const CustomDatePickerWidget({
    super.key,
    required this.title,
    required this.controller,
    this.validator,
    this.onTap,
  });

  final String title;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelText(value: title),
        SizedBox(
          height: 10,
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          readOnly: true,
          style:
              Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(
                color: Colors.black,
              ),
          decoration: InputDecoration(
            errorStyle: TextStyle(fontSize: 0),
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
          onTap: onTap,
        ),
      ],
    );
  }
}
