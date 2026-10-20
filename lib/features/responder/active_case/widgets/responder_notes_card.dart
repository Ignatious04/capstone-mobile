import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/models/responder_note_model.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/utilities/formatter.dart';
import 'package:capstone/features/public_user/reporting/widgets/empty_card.dart';
import 'package:flutter/material.dart';

class ResponderNotesCard extends StatelessWidget {
  const ResponderNotesCard({super.key, required this.notes});

  final List<ResponderNoteModel> notes;

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
              LabelText(
                value: [
                  if (ordered[i].authorName.isNotEmpty) ordered[i].authorName,
                  if (ordered[i].createdAt != null) Formatter.formatDateTime(ordered[i].createdAt!, locale),
                ].join(' • '),
                color: Colors.black54,
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