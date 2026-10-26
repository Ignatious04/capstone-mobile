import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/models/response_model.dart';
import 'package:capstone/features/responder/active_case/providers/responder_note_provider.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/features/responder/active_case/widgets/responder_notes_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResponderNotesSection extends StatelessWidget {
  const ResponderNotesSection({super.key, required this.response});

  final ResponseModel response;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(icon: Icons.edit_note, title: l10n.responderNotes),
        const SizedBox(height: 10),
        ResponderNotesCard(notes: response.responderNotes),
        const SizedBox(height: 10),
        CustomElevatedButton(
          // The screen has a fixed-height map above the details, so typing
          // inline would be squeezed by the keyboard. A bottom sheet avoids that.
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (_) => _AddNoteSheet(responseID: response.responseID),
          ),
          value: l10n.addNote,
          icon: const Icon(Icons.add_comment_outlined),
        ),
      ],
    );
  }
}

class _AddNoteSheet extends ConsumerStatefulWidget {
  const _AddNoteSheet({required this.responseID});

  final String responseID;

  @override
  ConsumerState<_AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends ConsumerState<_AddNoteSheet> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final error = await ref
        .read(responderNoteProvider.notifier)
        .addNote(
          responseID: widget.responseID,
          text: _controller.text,
          l10n: AppLocalizations.of(context)!,
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
    final canSave = !isSaving && _controller.text.trim().isNotEmpty;

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
                title: l10n.addNote.toUpperCase(),
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