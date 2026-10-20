import 'dart:async';

import 'package:capstone/core/constants/timeouts.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/models/responder_note_model.dart';
import 'package:capstone/core/shared/providers/report_repository_provider.dart';
import 'package:capstone/core/shared/providers/responder_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// state == true while a note is being saved.
final responderNoteProvider = NotifierProvider<ResponderNoteNotifier, bool>(
  ResponderNoteNotifier.new,
);

class ResponderNoteNotifier extends Notifier<bool> {
  static const maxLength = 500;

  @override
  bool build() => false;

  /// Returns null on success (or if there was nothing to save), else an error message.
  Future<String?> addNote({
    required String reportID,
    required String text,
    required AppLocalizations l10n,
  }) async {
    final trimmed = text.trim();
    if (state || trimmed.isEmpty) return null;

    final responder = ref.read(currentAuthenticatedResponderProvider).value;
    if (responder == null) return l10n.noteSaveError;

    state = true;
    try {
      await ref
          .read(reportRepositoryProvider)
          .addResponderNote(
            reportID,
            ResponderNoteModel(
              text: trimmed,
              authorID: responder.id,
              authorName: responder.fullName,
              createdAt: DateTime.now(),
            ),
          )
          .timeout(kReportWriteTimeout);
      return null;
    } on TimeoutException {
      // Offline: Firestore keeps the write queued and the note already shows
      // locally, so treat it as saved. It syncs when the connection returns.
      return null;
    } catch (_) {
      return l10n.noteSaveError;
    } finally {
      state = false;
    }
  }
}