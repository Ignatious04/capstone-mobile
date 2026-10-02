class RealtimeResponderLocationModel {
  final String reportID;
  final String responderID;
  final String userID;
  final double latitude;
  final double longitude;
  final DateTime updatedAt;

  const RealtimeResponderLocationModel({
    required this.reportID,
    required this.responderID,
    required this.userID,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'reportID': reportID,
    'responderID': responderID,
    'userID': userID,
    'latitude': latitude,
    'longitude': longitude,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory RealtimeResponderLocationModel.fromMap(Map<String, dynamic> map) {
    return RealtimeResponderLocationModel(
      reportID: map['reportID'] ?? '',
      responderID: map['responderID'] ?? '',
      userID: map['userID'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
