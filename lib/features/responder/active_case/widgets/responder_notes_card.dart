import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/models/responder_note_model.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/utilities/formatter.dart';
import 'package:capstone/features/public_user/reporting/widgets/empty_card.dart';
import 'package:flutter/material.dart';

class ResponderNotesCard extends StatelessWidget {
  const ResponderNotesCard({
    super.key,
    required this.notes,
    this.currentUserID,
    this.onEdit,
    this.onDelete,
  });

  final List<ResponderNoteModel> notes;
  final String? currentUserID;
  final ValueChanged<ResponderNoteModel>? onEdit;
  final ValueChanged<ResponderNoteModel>? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    if (notes.isEmpty) {
      return EmptyCard(
        icon: Icons.sticky_note_2_outlined,
        message: l10n.noNotes,
      );
    }

    // arrayUnion appends, so the stored order is oldest -> newest. Show newest first.
    final ordered = notes.reversed.toList();

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < ordered.length; i++) ...[
              if (i > 0) const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: LabelText(
                      value: [
                        if (ordered[i].authorName.isNotEmpty) ordered[i].authorName,
                        if (ordered[i].createdAt != null) Formatter.formatDateTime(ordered[i].createdAt!, locale),
                        if (ordered[i].editedAt != null) l10n.edited,
                      ].join(' • '),
                      color: Colors.black54,
                    ),
                  ),
                  if (currentUserID != null && ordered[i].authorID == currentUserID) ...[
                    if (onEdit != null)
                      _NoteAction(
                        icon: Icons.edit_outlined,
                        tooltip: l10n.editNote,
                        onTap: () => onEdit!(ordered[i]),
                      ),
                    if (onDelete != null)
                      _NoteAction(
                        icon: Icons.delete_outline,
                        color: Colors.red,
                        tooltip: l10n.deleteNote,
                        onTap: () => onDelete!(ordered[i]),
                      ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              BodyText(value: ordered[i].text),
            ],
          ],
        ),
      ),
    );
  }
}

class _NoteAction extends StatelessWidget {
  const _NoteAction({required this.icon, required this.tooltip, required this.onTap, this.color});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20, color: color ?? Colors.black54),
      tooltip: tooltip,
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(),
    );
  }
}
