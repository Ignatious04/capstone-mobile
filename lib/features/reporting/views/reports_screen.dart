import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/report_card_widget.dart';
import 'package:capstone/core/shared/widgets/text/deprecated/text_title_small.dart';
import 'package:capstone/features/reporting/providers/report_repository_provider.dart';
import 'package:capstone/features/reporting/views/reports_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(reportsStreamProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: const CustomHeaderWidget(title: "Reports", body: "Tell us what you need"),
            ),
            Expanded(
              child: reports.when(
                data: (reports) {
                  if (reports.isEmpty) {
                    return const Center(
                      child: TextTitleSmall(
                        title: "No reports yet.",
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ReportCardWidget(
                          referenceNumber: report.referenceNumber,
                          emergencyType: report.incidentType!.name,
                          createdAt: DateFormat("MMMM dd, yyyy").format(report.createdAt!),
                          status: report.status!.name,
                          report: report,
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CustomCircularProgressIndicator(),
                ),
                error: (e, _) => Center(
                  child: Text(e.toString()),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "reportsFAB",
        onPressed: () async {
          final submitted = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const ReportsFormScreen(),
            ),
          );

          if (submitted == true && mounted) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        },
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }
}
