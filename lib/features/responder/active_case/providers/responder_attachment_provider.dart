import 'package:capstone/core/constants/timeouts.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/models/attachment_model.dart';
import 'dart:io';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/response_repository_provider.dart';
import 'package:capstone/core/shared/providers/storage_repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// state == true while an upload or delete is in progress.
final responderAttachmentProvider = NotifierProvider<ResponderAttachmentNotifier, bool>(
  ResponderAttachmentNotifier.new,
);

class ResponderAttachmentNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Returns null on success (or if the picker was cancelled), else an error message.
  Future<String?> addImage({
    required String reportID,
    required String responseID,
    required ImageSource source,
    required AppLocalizations l10n,
  }) async {
    if (state) return null;

    final picker = ImagePicker();
    final List<XFile> picked;
    if (source == ImageSource.gallery) {
      picked = await picker.pickMultiImage(
        imageQuality: 75,
        maxWidth: 1920,
      );
    } else {
      final image = await picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 1920,
      );
      picked = image == null ? [] : [image];
    }
    if (picked.isEmpty) return null;

    state = true;
    try {
      final responderID = ref.read(firebaseAuthProvider).currentUser!.uid;
      // Sequential on purpose: file names are based on the millisecond timestamp,
      // so parallel uploads could collide.
      for (final image in picked) {
        final attachment = await ref
            .read(storageRepositoryProvider)
            .uploadResponderAttachment(
              file: File(image.path),
              reportID: reportID,
              responderID: responderID,
            );
        await ref.read(responseRepositoryProvider).addAttachment(responseID, attachment);
      }
      return null;
    } catch (e, st) {
      debugPrint('Responder attachment failed: $e\n$st');
      return l10n.uploadError;
    } finally {
      state = false;
    }
  }

    /// Returns null on success, else an error message.
  Future<String?> removeImage({
    required String responseID,
    required AttachmentModel attachment,
    required AppLocalizations l10n,
  }) async {
    if (state) return null;
    state = true;
    try {
      await ref
          .read(responseRepositoryProvider)
          .removeAttachment(responseID, attachment.url)
          .timeout(kReportWriteTimeout);
    } catch (e, st) {
      debugPrint('Responder attachment delete failed: $e\n$st');
      state = false;
      return l10n.imageDeleteError;
    }
    // The Firestore entry is gone, so the file is only cleanup. A failure
    // here just leaves an orphaned file, which isn't worth showing the user.
    try {
      await ref.read(storageRepositoryProvider).deleteByUrl(attachment.url);
    } catch (e) {
      debugPrint('Storage cleanup failed: $e');
    }
    state = false;
    return null;
  }
}
