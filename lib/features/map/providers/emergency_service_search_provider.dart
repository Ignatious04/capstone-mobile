import 'package:flutter_riverpod/flutter_riverpod.dart';

final emergencyServiceSearchProvider = NotifierProvider<EmergencyServiceSearchNotifier, String>(
  EmergencyServiceSearchNotifier.new,
);

class EmergencyServiceSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    print("Query set to: $query");
    state = query;
  }
}
