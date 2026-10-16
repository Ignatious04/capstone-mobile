import 'package:intl/intl.dart';

abstract final class Formatter {
  static String formatEnumName(String value) {
    final formatted = value.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    return formatted
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  static String formatDateTime(DateTime value, String locale) => DateFormat('MMM dd, yyyy • h:mm a', locale).format(value);
}
