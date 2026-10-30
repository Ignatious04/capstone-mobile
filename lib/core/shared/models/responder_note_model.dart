import 'package:cloud_firestore/cloud_firestore.dart';

class ResponderNoteModel {
  final String text;
  final String authorID;
  final String authorName;
  final DateTime? createdAt;
  final DateTime? editedAt;

  const ResponderNoteModel({
    this.text = '',
    this.authorID = '',
    this.authorName = '',
    this.createdAt,
    this.editedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'authorID': authorID,
      'authorName': authorName,
      // FieldValue.serverTimestamp() isn't allowed inside arrayUnion, so this
      // is the device clock (same approach as AttachmentModel.uploadedAt).
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (editedAt != null) 'editedAt': Timestamp.fromDate(editedAt!),
    };
  }

  factory ResponderNoteModel.fromMap(Map<String, dynamic> map) {
    return ResponderNoteModel(
      text: map['text'] ?? '',
      authorID: map['authorID'] ?? '',
      authorName: map['authorName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      editedAt: (map['editedAt'] as Timestamp?)?.toDate(),
    );
  }
}