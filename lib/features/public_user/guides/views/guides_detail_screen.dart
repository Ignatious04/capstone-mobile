import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/l10n/enum_labels.dart';
import 'package:capstone/core/shared/providers/locale_provider.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/legal_document_view.dart';
import 'package:capstone/core/utilities/call_nearest_service.dart';
import 'package:capstone/features/public_user/guides/models/guides_model.dart';
import 'package:capstone/features/public_user/guides/providers/guides_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GuideDetailScreen extends ConsumerWidget {
  const GuideDetailScreen({super.key, required this.guide});

  final GuideSummary guide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dir = guidesAssetDir(ref.watch(localeProvider).languageCode);
    final path = '$dir/${guide.id}.md';

    return Scaffold(
      appBar: CustomAppBar(value: guide.title),
      body: SafeArea(
        child: Column(
          children: [
            // LegalDocumentView already renders headings, lists and bold callouts.
            Expanded(child: LegalDocumentView(key: ValueKey(path), assetPath: path)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: CustomElevatedButton(
                  onPressed: () => callNearestService(
                    context,
                    ref,
                    guide.type,
                    source: 'guide_${guide.id}',
                  ),
                  value: l10n.callServiceType(guide.type.label(l10n)),
                  icon: const Icon(Icons.call),
                  color: Colors.white,
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}