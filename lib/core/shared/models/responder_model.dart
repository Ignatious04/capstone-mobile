import 'package:capstone/core/enums/service_type_enum.dart';

class ResponderModel {
  final String responderId;
  final String firstName;
  final String lastName;
  final ServiceTypeEnum serviceType;
  final bool isActive;

  const ResponderModel({
    this.responderId = "",
    this.firstName = "",
    this.lastName = "",
    this.serviceType = ServiceTypeEnum.medical,
    this.isActive = true,
  });

  factory ResponderModel.fromMap(Map<dynamic, dynamic> map) {
    return ResponderModel(
      responderId: map['responderId'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      serviceType: ServiceTypeEnum.values.byName(map['serviceType'] ?? 'medical'),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'responderId': responderId,
      'firstName': firstName,
      'lastName': lastName,
      'serviceType': serviceType.name,
      'isActive': isActive,
    };
  }
}
