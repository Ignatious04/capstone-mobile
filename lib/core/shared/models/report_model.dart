import 'package:capstone/core/enums/police_concern_enum.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/enums/report_priority_enum.dart';
import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/enums/report_type_enum.dart';
import 'package:capstone/core/shared/models/responder_note_model.dart';
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
  final List<AttachmentModel> responderAttachments;
  final List<ResponderNoteModel> responderNotes;
  final List<PreCallGuidanceModel> guidanceAnswers;
  final String additionalInformation;
  final ReportStatusEnum? status;
  final GeoPoint? location;
  final DateTime? createdAt;
  final String? assignedTo;
  final double? locationAccuracy;
  final String? locationDescription;
  final GeoPoint? originalGpsLocation;
  final DateTime? acceptedAt;
  final DateTime? dispatchedAt;
  final DateTime? arrivedAt;
  final DateTime? resolvedAt;
  final List<ServiceTypeEnum> secondaryServices;

  /// ETA recorded when the responder went en route (frozen snapshot, not live).
  final int? etaSeconds;
  final double? etaDistanceMeters;

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
    this.responderAttachments = const [],
    this.responderNotes = const [],
    this.guidanceAnswers = const [],
    this.additionalInformation = '',
    this.status = ReportStatusEnum.pending,
    this.location,
    this.createdAt,
    this.assignedTo,
    this.locationAccuracy,
    this.locationDescription,
    this.originalGpsLocation,
    this.acceptedAt,
    this.dispatchedAt,
    this.arrivedAt,
    this.resolvedAt,
    this.secondaryServices = const [],
    this.etaSeconds,
    this.etaDistanceMeters,
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
    List<AttachmentModel>? responderAttachments,
    List<ResponderNoteModel>? responderNotes,
    List<PreCallGuidanceModel>? guidanceAnswers,
    String? additionalInformation,
    ReportStatusEnum? status,
    GeoPoint? location,
    DateTime? createdAt,
    String? assignedTo,
    double? locationAccuracy,
    String? locationDescription,
    GeoPoint? originalGpsLocation,
    DateTime? acceptedAt,
    DateTime? dispatchedAt,
    DateTime? arrivedAt,
    DateTime? resolvedAt,
    List<ServiceTypeEnum>? secondaryServices,
    int? etaSeconds,
    double? etaDistanceMeters,
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
      responderAttachments: responderAttachments ?? this.responderAttachments,
      responderNotes: responderNotes ?? this.responderNotes,
      guidanceAnswers: guidanceAnswers ?? this.guidanceAnswers,
      additionalInformation: additionalInformation ?? this.additionalInformation,
      status: status ?? this.status,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      assignedTo: assignedTo ?? this.assignedTo,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
      locationDescription: locationDescription ?? this.locationDescription,
      originalGpsLocation: originalGpsLocation ?? this.originalGpsLocation,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      dispatchedAt: dispatchedAt ?? this.dispatchedAt,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      secondaryServices: secondaryServices ?? this.secondaryServices,
      etaSeconds: etaSeconds ?? this.etaSeconds,
      etaDistanceMeters: etaDistanceMeters ?? this.etaDistanceMeters,
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
      'responderAttachments': responderAttachments.map((a) => a.toMap()).toList(),
      'responderNotes': responderNotes.map((n) => n.toMap()).toList(),
      'guidanceAnswers': guidanceAnswers.map((e) => e.toMap()).toList(),
      'additionalInformation': additionalInformation,
      'status': status?.name,
      'location': location,
      'createdAt': createdAt,
      "assignedTo": assignedTo,
      'locationAccuracy': locationAccuracy,
      'locationDescription': locationDescription,
      'originalGpsLocation': originalGpsLocation,
      'acceptedAt': acceptedAt,
      'dispatchedAt': dispatchedAt,
      "arrivedAt": arrivedAt,
      'resolvedAt': resolvedAt,
      'secondaryServices': secondaryServices.map((s) => s.name).toList(),
      'etaSeconds': etaSeconds,
      'etaDistanceMeters': etaDistanceMeters,
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
      responderAttachments: (map['responderAttachments'] as List<dynamic>? ?? [])
          .map((a) => AttachmentModel.fromMap(Map<String, dynamic>.from(a)))
          .toList(),
      responderNotes: (map['responderNotes'] as List<dynamic>? ?? [])
          .map((n) => ResponderNoteModel.fromMap(Map<String, dynamic>.from(n)))
          .toList(),
      guidanceAnswers: (map['guidanceAnswers'] as List<dynamic>? ?? [])
          .map((e) => PreCallGuidanceModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      additionalInformation: map['additionalInformation'] ?? '',
      status: map['status'] != null ? ReportStatusEnum.values.firstWhere((e) => e.name == map['status']) : null,
      location: map['location'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      assignedTo: map["assignedTo"] ?? "",
      locationAccuracy: (map['locationAccuracy'] as num?)?.toDouble(),
      locationDescription: map['locationDescription'],
      originalGpsLocation: map['originalGpsLocation'],
      acceptedAt: (map['acceptedAt'] as Timestamp?)?.toDate(),
      dispatchedAt: (map["dispatchedAt"] as Timestamp?)?.toDate(),
      arrivedAt: (map["arrivedAt"] as Timestamp?)?.toDate(),
      resolvedAt: (map['resolvedAt'] as Timestamp?)?.toDate(),
      secondaryServices: (map['secondaryServices'] as List<dynamic>? ?? [])
          .map((s) => ServiceTypeEnum.values.firstWhere((e) => e.name == s))
          .toList(),
      etaSeconds: (map['etaSeconds'] as num?)?.toInt(),
      etaDistanceMeters: (map['etaDistanceMeters'] as num?)?.toDouble(),
    );
  }
}
