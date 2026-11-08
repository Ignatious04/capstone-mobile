import 'dart:math';

class ReferenceNumberGenerator {
  static String generate(DateTime now) {
    final date = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    return "RPT-$date-${Random.secure().nextInt(90000000) + 10000000}";
  }
}
