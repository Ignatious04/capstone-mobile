import 'package:capstone/core/shared/widgets/text/text_body_small.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.title,
    this.controller,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.isReadOnly = false,
    this.color = Colors.black,
    this.hideErrorText = true,
    this.vertical = 10,
    this.horizontal = 10,
    this.maxLines = 1,
    this.onChanged,
  });

  final String title;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool isReadOnly;
  final Color color;
  final bool hideErrorText;
  final double vertical;
  final double horizontal;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextBodySmall(title: title),
        SizedBox(
          height: 10,
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          readOnly: isReadOnly,
          style: TextStyle(fontSize: 14, color: color),
          decoration: InputDecoration(
            errorStyle: hideErrorText
                ? const TextStyle(
                    fontSize: 0,
                  )
                : null,
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: vertical,
              horizontal: horizontal,
            ),
          ),
          onChanged: onChanged,
          onTapOutside: (_) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
        ),
      ],
    );
  }
}
