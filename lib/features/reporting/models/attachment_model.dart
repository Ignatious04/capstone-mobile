class AttachmentModel {
  final String attachmentID;
  final String fileName;
  final String fileURL;
  final String contentType;
  final DateTime? uploadedAt;

  const AttachmentModel({
    this.attachmentID = '',
    this.fileName = '',
    this.fileURL = '',
    this.contentType = '',
    this.uploadedAt,
  });

  AttachmentModel copyWith({
    String? attachmentID,
    String? fileName,
    String? fileURL,
    String? contentType,
    DateTime? uploadedAt,
  }) {
    return AttachmentModel(
      attachmentID: attachmentID ?? this.attachmentID,
      fileName: fileName ?? this.fileName,
      fileURL: fileURL ?? this.fileURL,
      contentType: contentType ?? this.contentType,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'attachmentID': attachmentID,
      'fileName': fileName,
      'fileURL': fileURL,
      'contentType': contentType,
      'uploadedAt': uploadedAt,
    };
  }

  factory AttachmentModel.fromMap(Map<String, dynamic> map) {
    return AttachmentModel(
      attachmentID: map['attachmentID'] ?? '',
      fileName: map['fileName'] ?? '',
      fileURL: map['fileURL'] ?? '',
      contentType: map['contentType'] ?? '',
      uploadedAt: map['uploadedAt']?.toDate(),
    );
  }
}
