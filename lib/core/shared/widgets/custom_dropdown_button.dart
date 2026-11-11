import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class CustomDropdownButton<T> extends StatefulWidget {
  const CustomDropdownButton({
    super.key,
    required this.title,
    required this.items,
    this.validator,
    this.hideErrorText = true,
    this.onChanged,
    this.value,
    this.isRequired = false,
    this.isExpanded = false,
  });

  final String title;
  final bool hideErrorText;
  final List<DropdownMenuItem<T>> items;
  final String? Function(T?)? validator;
  final ValueChanged<T?>? onChanged;
  final T? value;
  final bool isRequired;
  final bool isExpanded;

  @override
  State<CustomDropdownButton<T>> createState() => _CustomDropdownButtonState<T>();
}

class _CustomDropdownButtonState<T> extends State<CustomDropdownButton<T>> {
  final _fieldKey = GlobalKey<FormFieldState<T>>();
  T? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.value;
  }

  // Only optional, enabled fields that currently hold a value can be cleared.
  bool get _canClear => !widget.isRequired && widget.onChanged != null && _selected != null;

  void _handleChanged(T? value) {
    setState(() => _selected = value);
    widget.onChanged?.call(value);
  }

  // didChange resets the field's internal value AND calls onChanged(null).
  void _clear() => _fieldKey.currentState?.didChange(null);

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
        const SizedBox(height: 10),
        DropdownButtonFormField<T>(
          key: _fieldKey,
          initialValue: widget.value,
          validator: widget.validator,
          menuMaxHeight: 300.0,
          isExpanded: widget.isExpanded,
          decoration: InputDecoration(
            errorStyle: widget.hideErrorText
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
            suffixIcon: _canClear
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                    visualDensity: VisualDensity.compact,
                    onPressed: _clear,
                  )
                : null,
          ),
          items: widget.items,
          onChanged: widget.onChanged == null ? null : _handleChanged,
        ),
      ],
    );
  }
}
