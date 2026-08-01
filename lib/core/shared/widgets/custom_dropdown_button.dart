import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class CustomDropdownButton<T> extends StatelessWidget {
  const CustomDropdownButton({
    super.key,
    required this.title,
    required this.items,
    this.validator,
    this.hideErrorText = true,
    this.onChanged,
    this.value,
    this.isRequired = false,
  });

  final String title;
  final bool hideErrorText;
  final List<DropdownMenuItem<T>> items;
  final String? Function(T?)? validator;
  final ValueChanged<T?>? onChanged;
  final T? value;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style:
                Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(
                  color: AppColors.darkerGrey,
                  fontWeight: FontWeight.bold,
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
        const SizedBox(height: 10),
        DropdownButtonFormField<T>(
          initialValue: value,
          validator: validator,
          decoration: InputDecoration(
            errorStyle: hideErrorText
                ? const TextStyle(
                    fontSize: 0,
                  )
                : null,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
