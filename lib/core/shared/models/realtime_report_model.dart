import 'package:capstone/core/enums/report_status_enum.dart';

class RealtimeReportModel {
  final String reportID;
  final String referenceNumber;
  final ReportStatusEnum status;
  final double latitude;
  final double longitude;
  final DateTime updatedAt;

  const RealtimeReportModel({
    required this.reportID,
    required this.referenceNumber,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reportID': reportID,
      'referenceNumber': referenceNumber,
      'status': status.name,
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory RealtimeReportModel.fromMap(Map<String, dynamic> map) {
    return RealtimeReportModel(
      reportID: map['reportID'] ?? '',
      referenceNumber: map['referenceNumber'] ?? '',
      status: ReportStatusEnum.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReportStatusEnum.pending,
      ),
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}