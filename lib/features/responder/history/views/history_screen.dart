import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/features/responder/history/providers/history_provider.dart';
import 'package:capstone/features/responder/history/widgets/history_case_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResponderHistoryScreen extends ConsumerWidget {
  const ResponderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final history = ref.watch(responderHistoryProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: CustomHeaderWidget(
                title: l10n.history,
                body: l10n.historySubtitle,
              ),
            ),
            Expanded(
              child: history.when(
                data: (cases) {
                  if (cases.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.emergency_outlined,
                          size: 100,
                          color: Colors.black54,
                        ),
                        const SizedBox(height: 10),
                        TitleText(value: l10n.noResolvedCases),
                      ],
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: cases.length,
                    itemBuilder: (context, index) => HistoryCaseCard(response: cases[index]),
                  );
                },
                loading: () => const Center(child: CustomCircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
