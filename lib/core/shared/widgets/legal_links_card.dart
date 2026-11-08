// lib/core/shared/widgets/legal_links_card.dart
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/public_user/register/views/privacy_policy_screen.dart';
import 'package:capstone/features/public_user/register/views/terms_and_conditions_screen.dart';
import 'package:flutter/material.dart';

class LegalLinksCard extends StatelessWidget {
  const LegalLinksCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.description_outlined, size: 25),
            title: BodyText(value: l10n.termsAndConditions),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen()),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, size: 25),
            title: BodyText(value: l10n.privacyPolicy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
