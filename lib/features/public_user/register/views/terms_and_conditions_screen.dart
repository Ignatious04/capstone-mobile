import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/legal_document_view.dart';
import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(value: "Terms and Conditions"),
      body: const SafeArea(
        child: LegalDocumentView(assetPath: 'assets/legal/terms_and_conditions.txt'),
      ),
    );
  }
}