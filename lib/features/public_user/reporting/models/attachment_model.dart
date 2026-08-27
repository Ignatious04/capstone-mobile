class AttachmentModel {
  final String fileName;
  final String url;
  final String type;

  const AttachmentModel({
    this.fileName = '',
    this.url = '',
    this.type = '',
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
    };
  }

  factory AttachmentModel.fromMap(Map<String, dynamic> map) {
    return AttachmentModel(
      fileName: map['fileName'] ?? '',
      url: map['url'] ?? '',
      type: map['contentType'] ?? '',
    );
  }
}
