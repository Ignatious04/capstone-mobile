import 'package:capstone/core/shared/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Compact EN | FIL toggle. Use [onDark] on the deepOrange header.
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key, this.onDark = false});

  final bool onDark;

  static const _options = [
    ('en', 'EN', 'English'),
    ('fil', 'FIL', 'Filipino'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider).languageCode;
    final selectedBg = onDark ? Colors.white : Colors.deepOrange;
    final selectedFg = onDark ? Colors.deepOrange : Colors.white;
    final idleFg = onDark ? Colors.white : Colors.black87;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: onDark ? Colors.white : Colors.black26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (code, short, full) in _options)
            Semantics(
              button: true,
              selected: current == code,
              label: full,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => ref.read(localeProvider.notifier).state = Locale(code),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: current == code ? selectedBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    short,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: current == code ? selectedFg : idleFg,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}