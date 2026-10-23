import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResponderModel {
  final String id;
  final String fullName;
  final String email;
  final String contactNumber;
  final ServiceTypeEnum department;
  final String assignedAgencyID;
  final String role;
  final String responderCode;
  final bool isActive;
  final bool isAvailable;
  final DateTime? createdAt;

  const ResponderModel({
    this.id = "",
    this.fullName = "",
    this.email = "",
    this.contactNumber = "",
    this.department = ServiceTypeEnum.medical,
    this.assignedAgencyID = "",
    this.role = "",
    this.responderCode = "",
    this.isActive = true,
    this.isAvailable = true,
    this.createdAt,
  });

  factory ResponderModel.fromMap(Map<dynamic, dynamic> map) {
    return ResponderModel(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      department: ServiceTypeEnum.values.byName(map['department'] ?? 'medical'),
      assignedAgencyID: map['assignedAgencyID'] ?? '',
      role: map['role'] ?? '',
      responderCode: map['responderCode'] ?? '',
      isActive: map['isActive'] ?? true,
      isAvailable: map['isAvailable'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'contactNumber': contactNumber,
      'department': department.name,
      'assignedAgencyID': assignedAgencyID,
      'role': role,
      'responderCode': responderCode,
      'isActive': isActive,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
    };
  }
}
