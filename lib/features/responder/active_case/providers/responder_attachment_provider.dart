import 'package:capstone/core/l10n/app_localizations.dart';
import 'dart:io';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/response_repository_provider.dart';
import 'package:capstone/core/shared/providers/storage_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// state == true while an upload is in progress.
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

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 75,
      maxWidth: 1920,
    );
    if (picked == null) return null;

    state = true;
    try {
      final responderID = ref.read(firebaseAuthProvider).currentUser!.uid;
      final attachment = await ref
          .read(storageRepositoryProvider)
          .uploadResponderAttachment(
            file: File(picked.path),
            reportID: reportID,
            responderID: responderID,
          );
      await ref.read(responseRepositoryProvider).addAttachment(responseID, attachment);
      return null;
    } catch (_) {
      return l10n.uploadError;
    } finally {
      state = false;
    }
  }
}
