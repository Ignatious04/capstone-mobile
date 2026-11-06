import 'package:cloud_firestore/cloud_firestore.dart';

/// One dispatcher instruction on `responses/{id}.dispatchNotes` (append-only,
/// written by the web dashboard; read-only on mobile).
class DispatchNoteModel {
  final String text;
  final String authorID;
  final String authorName;
  final DateTime? createdAt;

  const DispatchNoteModel({
    this.text = '',
    this.authorID = '',
    this.authorName = '',
    this.createdAt,
  });

  factory DispatchNoteModel.fromMap(Map<String, dynamic> map) {
    // The rules don't constrain createdAt's type, so accept the likely shapes.
    DateTime? ts(Object? v) => switch (v) {
      Timestamp t => t.toDate(),
      int ms => DateTime.fromMillisecondsSinceEpoch(ms),
      String s => DateTime.tryParse(s),
      _ => null,
    };

    return DispatchNoteModel(
      text: (map['text'] as String? ?? '').trim(),
      authorID: map['authorID'] as String? ?? '',
      authorName: map['authorName'] as String? ?? '',
      createdAt: ts(map['createdAt']),
    );
  }
}