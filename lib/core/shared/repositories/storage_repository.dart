import 'dart:io';
import 'package:capstone/core/enums/attachment_type_enum.dart';
import 'package:capstone/features/reporting/models/attachment_model.dart';
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

    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    return AttachmentModel(
      fileName: fileName,
      url: url,
      type: AttachmentTypeEnum.image.name,
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
}
