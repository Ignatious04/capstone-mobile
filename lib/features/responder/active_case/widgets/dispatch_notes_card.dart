import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:flutter/material.dart';

/// Read-only dispatcher instructions. Renders nothing when there are none,
/// since responders can't write to this field.
class DispatchNotesSection extends StatelessWidget {
  const DispatchNotesSection({super.key, required this.notes});

  final String? notes;

  @override
  Widget build(BuildContext context) {
    if (notes == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

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
            child: BodyText(value: notes!),
          ),
        ),
      ],
    );
  }
}