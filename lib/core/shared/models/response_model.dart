import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/shared/models/attachment_model.dart';
import 'package:capstone/core/shared/models/responder_note_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// One service's response to a report: `responses/{reportID}_{serviceType}`.
/// Created by the onReportCreated Cloud Function, never by the client.
class ResponseModel {
  final String responseID;
  final String reportID;

  /// The reporter's uid, copied from the report so rules and queries don't
  /// need to read the report first.
  final String userID;
  final ServiceTypeEnum serviceType;
  final bool isPrimary;

  /// Station (emergencyServices doc ID) this response was routed to.
  final String? serviceID;
  final String? assignedTo;
  final ReportStatusEnum status;
  final DateTime? createdAt;
  final DateTime? acceptedAt;
  final DateTime? dispatchedAt;
  final DateTime? arrivedAt;
  final DateTime? resolvedAt;

  /// ETA recorded when the responder went en route (frozen snapshot, not live).
  final int? etaSeconds;
  final double? etaDistanceMeters;
  final List<ResponderNoteModel> responderNotes;
  final List<AttachmentModel> responderAttachments;

  const ResponseModel({
    required this.responseID,
    required this.reportID,
    required this.userID,
    required this.serviceType,
    this.isPrimary = false,
    this.serviceID,
    this.assignedTo,
    this.status = ReportStatusEnum.pending,
    this.createdAt,
    this.acceptedAt,
    this.dispatchedAt,
    this.arrivedAt,
    this.resolvedAt,
    this.etaSeconds,
    this.etaDistanceMeters,
    this.responderNotes = const [],
    this.responderAttachments = const [],
  });

  static String idFor(String reportID, ServiceTypeEnum type) => '${reportID}_${type.name}';

  factory ResponseModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime? ts(String key) => (map[key] as Timestamp?)?.toDate();
    final assigned = map['assignedTo'] as String?;

    return ResponseModel(
      responseID: id,
      reportID: map['reportID'] ?? '',
      userID: map['userID'] ?? '',
      serviceType: ServiceTypeEnum.values.byName(map['serviceType']),
      isPrimary: map['isPrimary'] ?? false,
      serviceID: map['serviceID'] as String?,
      assignedTo: (assigned == null || assigned.isEmpty) ? null : assigned,
      status: ReportStatusEnum.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReportStatusEnum.pending,
      ),
      createdAt: ts('createdAt'),
      acceptedAt: ts('acceptedAt'),
      dispatchedAt: ts('dispatchedAt'),
      arrivedAt: ts('arrivedAt'),
      resolvedAt: ts('resolvedAt'),
      etaSeconds: (map['etaSeconds'] as num?)?.toInt(),
      etaDistanceMeters: (map['etaDistanceMeters'] as num?)?.toDouble(),
      responderNotes: (map['responderNotes'] as List<dynamic>? ?? [])
          .map((n) => ResponderNoteModel.fromMap(Map<String, dynamic>.from(n)))
          .toList(),
      responderAttachments: (map['responderAttachments'] as List<dynamic>? ?? [])
          .map((a) => AttachmentModel.fromMap(Map<String, dynamic>.from(a)))
          .toList(),
    );
  }
}
