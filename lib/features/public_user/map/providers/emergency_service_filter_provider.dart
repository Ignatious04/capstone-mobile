import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final emergencyServiceFilterProvider = NotifierProvider<EmergencyServiceFilterNotifier, ServiceTypeEnum?>(
  EmergencyServiceFilterNotifier.new,
);

class EmergencyServiceFilterNotifier extends Notifier<ServiceTypeEnum?> {
  @override
  ServiceTypeEnum? build() => null;

  void setType(ServiceTypeEnum? type) {
    state = state == type ? null : type;
  }
}
