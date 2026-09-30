import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/features/responder/history/providers/history_provider.dart';
import 'package:capstone/features/responder/history/widgets/history_case_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResponderHistoryScreen extends ConsumerWidget {
  const ResponderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(responderHistoryProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              width: double.infinity,
              child: CustomHeaderWidget(
                title: "History",
                body: "Your resolved cases",
              ),
            ),
            Expanded(
              child: history.when(
                data: (cases) {
                  if (cases.isEmpty) {
                    return const Center(child: BodyText(value: "No resolved cases yet"));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: cases.length,
                    itemBuilder: (context, index) => HistoryCaseCard(report: cases[index]),
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