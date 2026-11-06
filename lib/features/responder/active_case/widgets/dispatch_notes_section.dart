import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/models/dispatch_note_model.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/utilities/formatter.dart';
import 'package:flutter/material.dart';

/// Read-only dispatcher instructions. Renders nothing when there are none.
class DispatchNotesSection extends StatelessWidget {
  const DispatchNotesSection({super.key, required this.notes});

  final List<DispatchNoteModel> notes;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final ordered = notes.reversed.toList(); // newest first

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        SectionTitle(icon: Icons.campaign_outlined, title: l10n.dispatcherNotes),
        const SizedBox(height: 10),
        Card(
          color: Colors.amber.shade50,
          elevation: 1,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.amber.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < ordered.length; i++) ...[
                  if (i > 0) const Divider(height: 24),
                  if (ordered[i].authorName.isNotEmpty || ordered[i].createdAt != null) ...[
                    LabelText(
                      value: [
                        if (ordered[i].authorName.isNotEmpty) ordered[i].authorName,
                        if (ordered[i].createdAt != null) Formatter.formatDateTime(ordered[i].createdAt!, locale),
                      ].join(' • '),
                      color: Colors.black54,
                    ),
                    const SizedBox(height: 4),
                  ],
                  BodyText(value: ordered[i].text),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}