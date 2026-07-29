import 'package:capstone/core/shared/widgets/text/text_body_small.dart';
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
  });

  final String title;
  final bool hideErrorText;
  final List<DropdownMenuItem<T>> items;

  final String? Function(T?)? validator;

  final ValueChanged<T?>? onChanged;
  final T? value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextBodySmall(title: title),
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
