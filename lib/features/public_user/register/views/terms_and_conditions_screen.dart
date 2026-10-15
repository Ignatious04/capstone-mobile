import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/legal_document_view.dart';
import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(value: l10n.termsAndConditions),
      body: const SafeArea(
        child: LegalDocumentView(assetPath: 'assets/legal/terms_and_conditions.txt'),
      ),
    );
  }
}