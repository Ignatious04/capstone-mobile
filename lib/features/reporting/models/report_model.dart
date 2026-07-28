import 'package:capstone/core/enums/guidance_type_enum.dart';
import 'package:capstone/core/enums/report_priority_enum.dart';
import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/features/reporting/models/victim_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String reportID;
  final String referenceNumber;

  final String userID;

  final GuidanceTypeEnum? type;
  final String description;

  final List<VictimModel> victims;
  final List<String> attachments;
  final String additionalInformation;

  final ReportStatusEnum? status;

  final GeoPoint? location;

  final String assignedAgencyID;

  final DateTime? createdAt;
  final DateTime? resolvedAt;

  const ReportModel({
    this.reportID = '',
    this.referenceNumber = '',
    this.userID = '',
    this.type,
    this.description = '',
    this.victims = const [],
    this.attachments = const [],
    this.additionalInformation = "",
    this.status,
    this.location,
    this.assignedAgencyID = '',
    this.createdAt,
    this.resolvedAt,
  });

  ReportModel copyWith({
    String? reportID,
    String? referenceNumber,
    String? userID,
    GuidanceTypeEnum? type,
    String? description,
    List<VictimModel>? victims,
    List<String>? attachments,
    String? additionalInformation,
    ReportStatusEnum? status,
    ReportPriorityEnum? priority,
    GeoPoint? location,
    String? assignedAgencyID,
    String? dispatcherID,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return ReportModel(
      reportID: reportID ?? this.reportID,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      userID: userID ?? this.userID,
      type: type ?? this.type,
      description: description ?? this.description,
      victims: victims ?? this.victims,
      attachments: attachments ?? this.attachments,
      additionalInformation: additionalInformation ?? this.additionalInformation,
      status: status ?? this.status,
      location: location ?? this.location,
      assignedAgencyID: assignedAgencyID ?? this.assignedAgencyID,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "reportID": reportID,
      'referenceNumber': referenceNumber,
      'userID': userID,
      'type': type?.name,
      'description': description,
      'victims': victims.map((v) => v.toMap()).toList(),
      'attachments': attachments,
      "additionalInformation": additionalInformation,
      'status': status!.name,
      'location': location,
      'assignedAgencyID': assignedAgencyID,
      'createdAt': createdAt,
      'resolvedAt': resolvedAt,
    };
  }

  factory ReportModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return ReportModel(
      reportID: map["reportID"] ?? "",
      referenceNumber: map['referenceNumber'] ?? '',
      userID: map['userID'] ?? '',
      type: map['type'] != null
          ? GuidanceTypeEnum.values.firstWhere(
              (e) => e.name == map['type'],
            )
          : null,
      description: map['description'] ?? '',
      victims: (map['victims'] as List<dynamic>? ?? [])
          .map(
            (v) => VictimModel.fromMap(
              Map<String, dynamic>.from(v),
            ),
          )
          .toList(),
      attachments: (map['attachments'] as List<dynamic>? ?? []).cast<String>(),
      additionalInformation: map["additionalInformation"] ?? "",
      status: map['status'] != null
          ? ReportStatusEnum.values.firstWhere(
              (e) => e.name == map['status'],
            )
          : null,
      location: map['location'],
      assignedAgencyID: map['assignedAgencyID'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      resolvedAt: (map['resolvedAt'] as Timestamp?)?.toDate(),
    );
  }
}
