import 'dart:async';
import 'dart:io';
import 'package:capstone/core/constants/timeouts.dart';
import 'package:capstone/core/enums/attachment_type_enum.dart';
import 'package:capstone/core/shared/models/attachment_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageRepository {
  StorageRepository(this._storage);

  final FirebaseStorage _storage;

  Future<AttachmentModel> uploadAttachment({
    required File file,
    required String reportID,
    required String fileName,
  }) async {
    final extension = path.extension(fileName);
    final storageFileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
    final ref = _storage.ref().child('reports/$reportID/$storageFileName');

    final task = ref.putFile(file);
    final String url;
    try {
      await task.timeout(kUploadTimeout);
      url = await ref.getDownloadURL().timeout(kUploadTimeout);
    } on TimeoutException {
      await task.cancel(); // don't leave the upload running in the background
      rethrow;
    }

    return AttachmentModel(
      fileName: fileName,
      url: url,
      type: AttachmentTypeEnum.image.name,
    );
  }

  Future<AttachmentModel> uploadResponderAttachment({
    required File file,
    required String reportID,
    required String responderID,
  }) async {
    final extension = path.extension(file.path);
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final ref = _storage.ref().child('reports/$reportID/responder/$stamp$extension');

    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    return AttachmentModel(
      fileName: 'responder_$stamp$extension',
      url: url,
      type: AttachmentTypeEnum.image.name,
      uploadedBy: responderID,
      uploadedAt: DateTime.now(),
    );
  }

  Future<String> uploadProfilePicture({
    required File file,
    required String userID,
    required String fileName,
  }) async {
    final extension = path.extension(fileName);
    final storageFileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
    final ref = _storage.ref().child('users/$userID/profile/$storageFileName');

    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    return url;
  }

  Future<String> uploadIdPicture({
    required File file,
    required String userID,
    required String fileName,
  }) async {
    final extension = path.extension(fileName);
    final storageFileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
    final ref = _storage.ref().child('users/$userID/id/$storageFileName');

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<List<AttachmentModel>> uploadAttachments({
    required String reportID,
    required List<File> files,
  }) async {
    final attachments = <AttachmentModel>[];

    for (final file in files) {
      final fileName = path.basename(file.path);

      final attachment = await uploadAttachment(
        file: file,
        reportID: reportID,
        fileName: fileName,
      );

      attachments.add(attachment);
    }

    return attachments;
  }

    /// Deletes the file behind a download URL. A missing file counts as deleted.
  Future<void> deleteByUrl(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
  }
}
