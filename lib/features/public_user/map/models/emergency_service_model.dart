import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyServiceModel {
  final String name;
  final ServiceTypeEnum type;
  final String contactNumber;
  final String address;
  final GeoPoint location;
  final bool isActive;

  const EmergencyServiceModel({
    this.name = '',
    this.type = ServiceTypeEnum.police,
    this.contactNumber = "",
    this.address = '',
    required this.location,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type.name,
      "contactNumber": contactNumber,
      'address': address,
      'location': location,
      'isActive': isActive,
    };
  }

  factory EmergencyServiceModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return EmergencyServiceModel(
      name: map['name'] ?? '',
      type: map['type'] != null
          ? ServiceTypeEnum.values.firstWhere(
              (e) => e.name == map['type'],
            )
          : ServiceTypeEnum.police,
      contactNumber: map["contactNumber"] ?? "",
      address: map['address'] ?? '',
      location: map['location'] as GeoPoint,
      isActive: map['isActive'] ?? true,
    );
  }
}
