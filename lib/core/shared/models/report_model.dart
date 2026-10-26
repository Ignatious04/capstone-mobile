import 'package:capstone/core/enums/police_concern_enum.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/enums/report_priority_enum.dart';
import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/enums/report_type_enum.dart';
import 'package:capstone/features/public_user/pre_call_guidance/models/pre_call_guidance_model.dart';
import 'package:capstone/core/shared/models/attachment_model.dart';
import 'package:capstone/features/public_user/reporting/models/victim_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String reportID;
  final String referenceNumber;
  final String userID;
  final ReportTypeEnum reportType;
  final ReportPriorityEnum? priority;
  final PoliceConcernTypeEnum? policeConcernType;
  final ServiceTypeEnum? incidentType;
  final String description;
  final List<VictimModel> victims;
  final List<AttachmentModel> attachments;
  final List<PreCallGuidanceModel> guidanceAnswers;
  final String additionalInformation;
  final ReportStatusEnum? status;
  final GeoPoint? location;
  final DateTime? createdAt;

  /// Station of the *primary* service. Each service's own station, responder,
  /// status, notes and attachments live in its `responses/{id}` document.
  /// Set by the onReportCreated Cloud Function, never by the client.
  final String? serviceID;
  final double? locationAccuracy;
  final String? locationDescription;
  final GeoPoint? originalGpsLocation;

  /// Set by the derive-status Cloud Function once every response is resolved.
  final DateTime? resolvedAt;
  final List<ServiceTypeEnum> secondaryServices;

  const ReportModel({
    this.reportID = '',
    this.referenceNumber = '',
    this.userID = '',
    this.reportType = ReportTypeEnum.normal,
    this.priority,
    this.policeConcernType,
    this.incidentType,
    this.description = '',
    this.victims = const [],
    this.attachments = const [],
    this.guidanceAnswers = const [],
    this.additionalInformation = '',
    this.status = ReportStatusEnum.pending,
    this.location,
    this.createdAt,
    this.serviceID,
    this.locationAccuracy,
    this.locationDescription,
    this.originalGpsLocation,
    this.resolvedAt,
    this.secondaryServices = const [],
  });

  ReportModel copyWith({
    String? reportID,
    String? referenceNumber,
    String? userID,
    ReportTypeEnum? reportType,
    ReportPriorityEnum? priority,
    PoliceConcernTypeEnum? policeConcernType,
    ServiceTypeEnum? incidentType,
    String? description,
    List<VictimModel>? victims,
    List<AttachmentModel>? attachments,
    List<PreCallGuidanceModel>? guidanceAnswers,
    String? additionalInformation,
    ReportStatusEnum? status,
    GeoPoint? location,
    DateTime? createdAt,
    String? serviceID,
    double? locationAccuracy,
    String? locationDescription,
    GeoPoint? originalGpsLocation,
    DateTime? resolvedAt,
    List<ServiceTypeEnum>? secondaryServices,
  }) {
    return ReportModel(
      reportID: reportID ?? this.reportID,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      userID: userID ?? this.userID,
      reportType: reportType ?? this.reportType,
      priority: priority ?? this.priority,
      policeConcernType: policeConcernType ?? this.policeConcernType,
      incidentType: incidentType ?? this.incidentType,
      description: description ?? this.description,
      victims: victims ?? this.victims,
      attachments: attachments ?? this.attachments,
      guidanceAnswers: guidanceAnswers ?? this.guidanceAnswers,
      additionalInformation: additionalInformation ?? this.additionalInformation,
      status: status ?? this.status,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      serviceID: serviceID ?? this.serviceID,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
      locationDescription: locationDescription ?? this.locationDescription,
      originalGpsLocation: originalGpsLocation ?? this.originalGpsLocation,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      secondaryServices: secondaryServices ?? this.secondaryServices,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reportID': reportID,
      'referenceNumber': referenceNumber,
      'userID': userID,
      'reportType': reportType.name,
      'priority': priority?.name,
      'policeConcernType': policeConcernType?.name,
      'incidentType': incidentType?.name,
      'description': description,
      'victims': victims.map((v) => v.toMap()).toList(),
      'attachments': attachments.map((a) => a.toMap()).toList(),
      'guidanceAnswers': guidanceAnswers.map((e) => e.toMap()).toList(),
      'additionalInformation': additionalInformation,
      'status': status?.name,
      'location': location,
      'createdAt': createdAt,
      'locationAccuracy': locationAccuracy,
      'locationDescription': locationDescription,
      'originalGpsLocation': originalGpsLocation,
      'resolvedAt': resolvedAt,
      'secondaryServices': secondaryServices.map((s) => s.name).toList(),
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      reportID: map['reportID'] ?? '',
      referenceNumber: map['referenceNumber'] ?? '',
      userID: map['userID'] ?? '',
      reportType: map['reportType'] != null
          ? ReportTypeEnum.values.firstWhere((e) => e.name == map['reportType'])
          : ReportTypeEnum.normal,
      priority: map['priority'] != null ? ReportPriorityEnum.values.firstWhere((e) => e.name == map['priority']) : null,
      policeConcernType: map['policeConcernType'] != null
          ? PoliceConcernTypeEnum.values.firstWhere((e) => e.name == map['policeConcernType'])
          : null,
      incidentType: map['incidentType'] != null
          ? ServiceTypeEnum.values.firstWhere((e) => e.name == map['incidentType'])
          : null,
      description: map['description'] ?? '',
      victims: (map['victims'] as List<dynamic>? ?? [])
          .map((v) => VictimModel.fromMap(Map<String, dynamic>.from(v)))
          .toList(),
      attachments: (map['attachments'] as List<dynamic>? ?? [])
          .map((a) => AttachmentModel.fromMap(Map<String, dynamic>.from(a)))
          .toList(),
      guidanceAnswers: (map['guidanceAnswers'] as List<dynamic>? ?? [])
          .map((e) => PreCallGuidanceModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      additionalInformation: map['additionalInformation'] ?? '',
      status: map['status'] != null ? ReportStatusEnum.values.firstWhere((e) => e.name == map['status']) : null,
      location: map['location'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      serviceID: map['serviceID'] as String?,
      locationAccuracy: (map['locationAccuracy'] as num?)?.toDouble(),
      locationDescription: map['locationDescription'],
      originalGpsLocation: map['originalGpsLocation'],
      resolvedAt: (map['resolvedAt'] as Timestamp?)?.toDate(),
      secondaryServices: (map['secondaryServices'] as List<dynamic>? ?? [])
          .map((s) => ServiceTypeEnum.values.firstWhere((e) => e.name == s))
          .toList(),
    );
  }
}
