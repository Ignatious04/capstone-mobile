import 'package:capstone/core/l10n/enum_labels.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/text/headline_text.dart';
import 'package:capstone/features/public_user/pre_call_guidance/models/pre_call_guidance_model.dart';
import 'package:capstone/features/public_user/pre_call_guidance/providers/guidance_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreCallGuidancePage extends ConsumerWidget {
  const PreCallGuidancePage({
    super.key,
    required this.question,
    required this.index,
    required this.onNext,
  });

  final PreCallGuidanceModel question;
  final int index;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HeadlineText(
          value: question.localizedQuestion(l10n),
          alignment: TextAlign.center,
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomElevatedButton(
              onPressed: () {
                ref.read(guidanceProvider.notifier).answerQuestion(index, false);
                onNext();
              },
              value: l10n.no.toUpperCase(),
              color: Colors.white,
              backgroundColor: Colors.deepOrange,
              hasPadding: true,
            ),
            const SizedBox(
              width: 10,
            ),
            CustomElevatedButton(
              onPressed: () {
                ref.read(guidanceProvider.notifier).answerQuestion(index, true);
                onNext();
              },
              value: l10n.yes.toUpperCase(),
              color: Colors.white,
              backgroundColor: Colors.deepOrange,
              hasPadding: true,
            ),
          ],
        ),
      ],
    );
  }
}
