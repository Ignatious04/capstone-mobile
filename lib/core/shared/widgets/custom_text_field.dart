import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
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
    this.color = AppColors.blackTextFull,
    this.obscureText = false,
    this.hideErrorText = true,
    this.vertical = 10,
    this.horizontal = 10,
    this.maxLines = 1,
    this.onChanged,
    this.isRequired = false,
    this.clearErrorWhenEmpty = true,
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

  /// When true, clearing the field removes its error until the next
  /// form-level validate() (e.g. on submit).
  final bool clearErrorWhenEmpty;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final _fieldKey = GlobalKey<FormFieldState<String>>();
  bool _isResetting = false;

  void _handleChanged(String value) {
    // reset() calls onChanged again, so guard against recursion.
    if (_isResetting) return;

    final field = _fieldKey.currentState;
    if (widget.clearErrorWhenEmpty && value.isEmpty && (field?.hasError ?? false)) {
      _isResetting = true;
      field!.reset(); // clears the error and the "user interacted" flag
      _isResetting = false;
    }

    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.blackTextMuted,
            ),
            children: [
              TextSpan(text: widget.title),
              if (widget.isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppColors.danger,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        TextFormField(
          key: _fieldKey,
          controller: widget.controller,
          enabled: widget.enabled,
          validator: widget.validator,
          autovalidateMode: widget.autovalidateMode,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          inputFormatters: widget.inputFormatters,
          readOnly: widget.isReadOnly,
          style:
              Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(
                color: widget.color,
              ),
          obscureText: widget.obscureText,
          decoration: InputDecoration(
            errorStyle: widget.hideErrorText
                ? const TextStyle(
                    fontSize: 0,
                  )
                : null,
            prefixText: widget.prefixText ?? "",
            prefixStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: widget.vertical,
              horizontal: widget.horizontal,
            ),
          ),
          onChanged: _handleChanged,
          onTapOutside: (_) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
        ),
      ],
    );
  }
}
