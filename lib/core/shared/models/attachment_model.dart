import 'package:cloud_firestore/cloud_firestore.dart';

class AttachmentModel {
  final String fileName;
  final String url;
  final String type;
  final String uploadedBy;
  final DateTime? uploadedAt;

  const AttachmentModel({
    this.fileName = '',
    this.url = '',
    this.type = '',
    this.uploadedBy = "",
    this.uploadedAt,
  });

  AttachmentModel copyWith({
    String? attachmentID,
    String? fileName,
    String? url,
    String? type,
  }) {
    return AttachmentModel(
      fileName: fileName ?? this.fileName,
      url: url ?? this.url,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'url': url,
      'contentType': type,
      if (uploadedBy.isNotEmpty) 'uploadedBy': uploadedBy,
      if (uploadedAt != null) 'uploadedAt': Timestamp.fromDate(uploadedAt!),
    };
  }

  factory AttachmentModel.fromMap(Map<String, dynamic> map) {
    return AttachmentModel(
      fileName: map['fileName'] ?? '',
      url: map['url'] ?? '',
      type: map['contentType'] ?? '',
      uploadedBy: map['uploadedBy'] ?? '',
      uploadedAt: (map['uploadedAt'] as Timestamp?)?.toDate(),
    );
  }
}
