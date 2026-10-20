import 'package:cloud_firestore/cloud_firestore.dart';

class ResponderNoteModel {
  final String text;
  final String authorID;
  final String authorName;
  final DateTime? createdAt;

  const ResponderNoteModel({
    this.text = '',
    this.authorID = '',
    this.authorName = '',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'authorID': authorID,
      'authorName': authorName,
      // FieldValue.serverTimestamp() isn't allowed inside arrayUnion, so this
      // is the device clock (same approach as AttachmentModel.uploadedAt).
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  factory ResponderNoteModel.fromMap(Map<String, dynamic> map) {
    return ResponderNoteModel(
      text: map['text'] ?? '',
      authorID: map['authorID'] ?? '',
      authorName: map['authorName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}