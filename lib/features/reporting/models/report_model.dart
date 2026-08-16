import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/enums/report_priority_enum.dart';
import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/enums/report_type_enum.dart';
import 'package:capstone/features/pre_call_guidance/models/pre_call_guidance_model.dart';
import 'package:capstone/features/reporting/models/attachment_model.dart';
import 'package:capstone/features/reporting/models/victim_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String reportID;
  final String referenceNumber;
  final String userID;
  final ReportTypeEnum reportType;
  final ServiceTypeEnum? incidentType;
  final String description;
  final List<VictimModel> victims;
  final List<AttachmentModel> attachments;
  final List<PreCallGuidanceModel> guidanceAnswers;
  final String additionalInformation;
  final ReportStatusEnum? status;
  final GeoPoint? location;
  final DateTime? createdAt;
  final DateTime? resolvedAt;

  const ReportModel({
    this.reportID = '',
    this.referenceNumber = '',
    this.userID = '',
    this.reportType = ReportTypeEnum.normal,
    this.incidentType,
    this.description = '',
    this.victims = const [],
    this.attachments = const [],
    this.guidanceAnswers = const [],
    this.additionalInformation = '',
    this.status = ReportStatusEnum.pending,
    this.location,
    this.createdAt,
    this.resolvedAt,
  });

  ReportModel copyWith({
    String? reportID,
    String? referenceNumber,
    String? userID,
    ReportTypeEnum? reportType,
    ServiceTypeEnum? incidentType,
    String? description,
    List<VictimModel>? victims,
    List<AttachmentModel>? attachments,
    List<PreCallGuidanceModel>? guidanceAnswers,
    String? additionalInformation,
    ReportStatusEnum? status,
    ReportPriorityEnum? priority,
    GeoPoint? location,
    String? dispatcherID,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return ReportModel(
      reportID: reportID ?? this.reportID,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      userID: userID ?? this.userID,
      reportType: reportType ?? this.reportType,
      incidentType: incidentType ?? this.incidentType,
      description: description ?? this.description,
      victims: victims ?? this.victims,
      attachments: attachments ?? this.attachments,
      guidanceAnswers: guidanceAnswers ?? this.guidanceAnswers,
      additionalInformation:
          additionalInformation ?? this.additionalInformation,
      status: status ?? this.status,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reportID': reportID,
      'referenceNumber': referenceNumber,
      'userID': userID,
      'reportType': reportType.name,
      'incidentType': incidentType?.name,
      'description': description,
      'victims': victims.map((v) => v.toMap()).toList(),
      'attachments': attachments.map((a) => a.toMap()).toList(),
      'guidanceAnswers': guidanceAnswers.map((e) => e.toMap()).toList(),
      'additionalInformation': additionalInformation,
      'status': status?.name,
      'location': location,
      'createdAt': createdAt,
      'resolvedAt': resolvedAt,
    };
  }

  factory ReportModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return ReportModel(
      reportID: map['reportID'] ?? '',
      referenceNumber: map['referenceNumber'] ?? '',
      userID: map['userID'] ?? '',

      reportType: map['reportType'] != null
          ? ReportTypeEnum.values.firstWhere(
              (e) => e.name == map['reportType'],
            )
          : ReportTypeEnum.normal,

      incidentType: map['incidentType'] != null
          ? ServiceTypeEnum.values.firstWhere(
              (e) => e.name == map['incidentType'],
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

      attachments: (map['attachments'] as List<dynamic>? ?? [])
          .map(
            (a) => AttachmentModel.fromMap(
              Map<String, dynamic>.from(a),
            ),
          )
          .toList(),

      guidanceAnswers: (map['guidanceAnswers'] as List<dynamic>? ?? [])
          .map(
            (e) => PreCallGuidanceModel.fromMap(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),

      additionalInformation: map['additionalInformation'] ?? '',

      status: map['status'] != null
          ? ReportStatusEnum.values.firstWhere(
              (e) => e.name == map['status'],
            )
          : null,

      location: map['location'],

      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),

      resolvedAt: (map['resolvedAt'] as Timestamp?)?.toDate(),
    );
  }
}