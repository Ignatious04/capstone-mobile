import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/shared/models/attachment_model.dart';
import 'package:capstone/core/shared/models/response_model.dart';
import 'package:capstone/core/shared/models/responder_note_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResponseRepository {
  ResponseRepository(this.firestore);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _responses => firestore.collection('responses');

  ResponseModel _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) => ResponseModel.fromMap(doc.id, doc.data());

  /// The responder's active case: their own unresolved response. By the time
  /// it reaches them the operator has already assigned and confirmed it, so
  /// status starts at `accepted` and moves through `dispatched` -> `onScene`
  /// -> `resolved`. Still one case at a time (first match).
  Stream<ResponseModel?> watchActiveResponse(String responderID) {
    return _responses
        .where('assignedTo', isEqualTo: responderID)
        .where('status', isNotEqualTo: ReportStatusEnum.resolved.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.isEmpty ? null : _fromDoc(snapshot.docs.first));
  }

  Stream<List<ResponseModel>> watchResolvedResponses(String responderID) {
    return _responses
        .where('assignedTo', isEqualTo: responderID)
        .where('status', isEqualTo: ReportStatusEnum.resolved.name)
        .orderBy('resolvedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }

  /// Every service's response to one report, primary first. `userID` is part
  /// of the query so it matches the "reporter can read" rule.
  Stream<List<ResponseModel>> watchForReport({required String reportID, required String userID}) {
    return _responses
        .where('reportID', isEqualTo: reportID)
        .where('userID', isEqualTo: userID)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map(_fromDoc).toList();
          list.sort((a, b) {
            if (a.isPrimary != b.isPrimary) return a.isPrimary ? -1 : 1;
            return a.serviceType.index.compareTo(b.serviceType.index);
          });
          return list;
        });
  }

  Future<void> updateStatus(
    String responseID,
    ReportStatusEnum status, {
    int? etaSeconds,
    double? etaDistanceMeters,
  }) {
    return _responses.doc(responseID).update({
      'status': status.name,
      if (status == ReportStatusEnum.dispatched) ...{
        'dispatchedAt': FieldValue.serverTimestamp(),
        'etaSeconds': ?etaSeconds,
        'etaDistanceMeters': ?etaDistanceMeters,
      },
      if (status == ReportStatusEnum.onScene) 'arrivedAt': FieldValue.serverTimestamp(),
      if (status == ReportStatusEnum.resolved) 'resolvedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addAttachment(String responseID, AttachmentModel attachment) {
    return _responses.doc(responseID).update({
      'responderAttachments': FieldValue.arrayUnion([attachment.toMap()]),
    });
  }

  /// Notes are appended here; edit/delete are below and only touch the
  /// caller's own notes (enforced by the Firestore rules).
  Future<void> addNote(String responseID, ResponderNoteModel note) {
    return _responses.doc(responseID).update({
      'responderNotes': FieldValue.arrayUnion([note.toMap()]),
    });
  }

    List<Map<String, dynamic>> _mapList(DocumentSnapshot<Map<String, dynamic>> snap, String field) =>
      (snap.data()?[field] as List<dynamic>? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();

  // Notes have no id, so match on author + creation time.
  bool _isNote(Map<String, dynamic> m, ResponderNoteModel n) =>
      m['authorID'] == n.authorID &&
      (m['createdAt'] as Timestamp?)?.millisecondsSinceEpoch == n.createdAt?.millisecondsSinceEpoch;

  Future<void> removeAttachment(String responseID, String url) {
    final doc = _responses.doc(responseID);
    return firestore.runTransaction((tx) async {
      final list = _mapList(await tx.get(doc), 'responderAttachments');
      final next = list.where((m) => m['url'] != url).toList();
      if (next.length == list.length) return; // already gone
      tx.update(doc, {'responderAttachments': next});
    });
  }

  Future<void> editNote(String responseID, ResponderNoteModel note, String newText) {
    final doc = _responses.doc(responseID);
    return firestore.runTransaction((tx) async {
      final notes = _mapList(await tx.get(doc), 'responderNotes');
      final i = notes.indexWhere((m) => _isNote(m, note));
      if (i == -1) return;
      // serverTimestamp() isn't allowed inside arrays, so device clock again.
      notes[i] = {...notes[i], 'text': newText, 'editedAt': Timestamp.now()};
      tx.update(doc, {'responderNotes': notes});
    });
  }

  Future<void> deleteNote(String responseID, ResponderNoteModel note) {
    final doc = _responses.doc(responseID);
    return firestore.runTransaction((tx) async {
      final notes = _mapList(await tx.get(doc), 'responderNotes');
      final i = notes.indexWhere((m) => _isNote(m, note));
      if (i == -1) return;
      notes.removeAt(i);
      tx.update(doc, {'responderNotes': notes});
    });
  }
}
