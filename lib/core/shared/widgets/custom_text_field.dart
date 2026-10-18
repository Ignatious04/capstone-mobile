import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.title,
    this.prefixText,
    this.controller,
    this.enabled = true,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteractionIfError,
    this.keyboardType,
    this.inputFormatters,
    this.isReadOnly = false,
    this.color = Colors.black,
    this.obscureText = false,
    this.hideErrorText = true,
    this.vertical = 10,
    this.horizontal = 10,
    this.maxLines = 1,
    this.onChanged,
    this.isRequired = false,
  });

  final String title;
  final String? prefixText;
  final TextEditingController? controller;
  final bool enabled;
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool isReadOnly;
  final Color color;
  final bool obscureText;
  final bool hideErrorText;
  final double vertical;
  final double horizontal;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.black54,
            ),
            children: [
              TextSpan(text: title),
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
          controller: controller,
          enabled: enabled,
          validator: validator,
          autovalidateMode: autovalidateMode,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          readOnly: isReadOnly,
          style:
              Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(
                color: color,
              ),
          obscureText: obscureText,
          decoration: InputDecoration(
            errorStyle: hideErrorText
                ? const TextStyle(
                    fontSize: 0,
                  )
                : null,
            prefixText: prefixText ?? "",
            prefixStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
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
