import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageRepository {
  StorageRepository(this._storage);

  final FirebaseStorage _storage;

  Future<String> uploadAttachment({
    required File file,
    required String reportID,
    required String fileName,
  }) async {
    final ref = _storage.ref().child(
      'reports/$reportID/$fileName',
    );

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }

  Future<List<String>> uploadAttachments({
    required String reportID,
    required List<File> files,
  }) async {
    final urls = <String>[];

    for (int i = 0; i < files.length; i++) {
      final url = await uploadAttachment(
        file: files[i],
        reportID: reportID,
        fileName: "${DateTime.now().millisecondsSinceEpoch}_$i.jpg",
      );

      urls.add(url);
    }

    return urls;
  }
}
