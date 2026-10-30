import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/models/responder_note_model.dart';
import 'package:capstone/core/shared/models/response_model.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/widgets/custom_alert_dialog.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/features/responder/active_case/providers/responder_note_provider.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/features/responder/active_case/widgets/responder_notes_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResponderNotesSection extends ConsumerWidget {
  const ResponderNotesSection({super.key, required this.response});

  final ResponseModel response;

  void _openSheet(BuildContext context, {ResponderNoteModel? note}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _NoteSheet(responseID: response.responseID, note: note),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, ResponderNoteModel note) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmationDialog(
      context,
      title: l10n.deleteNote,
      content: l10n.deleteNoteConfirm,
      cancelText: l10n.cancel,
      confirmText: l10n.delete,
    );
    if (confirmed != true || !context.mounted) return;

    final error = await ref
        .read(responderNoteProvider.notifier)
        .deleteNote(responseID: response.responseID, note: note, l10n: l10n);
    if (error != null && context.mounted) {
      CustomSnackbarHelper.show(context, text: error, color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final myUid = ref.watch(firebaseAuthProvider).currentUser?.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(icon: Icons.edit_note, title: l10n.responderNotes),
        const SizedBox(height: 10),
        ResponderNotesCard(
          notes: response.responderNotes,
          currentUserID: myUid,
          onEdit: (n) => _openSheet(context, note: n),
          onDelete: (n) => _delete(context, ref, n),
        ),
        const SizedBox(height: 10),
        CustomElevatedButton(
          onPressed: () => _openSheet(context),
          value: l10n.addNote,
          icon: const Icon(Icons.add_comment_outlined),
        ),
      ],
    );
  }
}

class _NoteSheet extends ConsumerStatefulWidget {
  const _NoteSheet({required this.responseID, this.note});

  final String responseID;
  final ResponderNoteModel? note; // non-null = editing

  @override
  ConsumerState<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends ConsumerState<_NoteSheet> {
  late final _controller = TextEditingController(text: widget.note?.text ?? '');
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(responderNoteProvider.notifier);
    final error = widget.note == null
        ? await notifier.addNote(responseID: widget.responseID, text: _controller.text, l10n: l10n)
        : await notifier.editNote(
            responseID: widget.responseID,
            note: widget.note!,
            text: _controller.text,
            l10n: l10n,
          );

    if (!mounted) return;
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSaving = ref.watch(responderNoteProvider);
    final text = _controller.text.trim();
    final canSave = !isSaving && text.isNotEmpty && text != widget.note?.text;

    return Padding(
      // Lift the sheet above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                title: (widget.note == null ? l10n.addNote : l10n.editNote).toUpperCase(),
                controller: _controller,
                enabled: !isSaving,
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                inputFormatters: [LengthLimitingTextInputFormatter(ResponderNoteNotifier.maxLength)],
                onChanged: (_) => setState(() => _error = null),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                BodyText(value: _error!, color: Colors.red),
              ],
              const SizedBox(height: 10),
              CustomElevatedButton(
                onPressed: canSave ? _save : null,
                value: l10n.save,
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
