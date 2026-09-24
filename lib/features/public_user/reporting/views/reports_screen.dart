import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/public_user/reporting/models/report_model.dart';
import 'package:capstone/features/public_user/reporting/widgets/report_card.dart';
import 'package:capstone/features/public_user/reporting/providers/report_repository_provider.dart';
import 'package:capstone/features/public_user/reporting/views/reports_form_screen.dart';
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

  Color _getStatusColor(ReportModel report) {
    switch (report.status) {
      case ReportStatusEnum.pending:
        return Colors.deepOrange;
      case ReportStatusEnum.accepted:
        return Colors.blue;
      case ReportStatusEnum.dispatched:
        return Colors.purple;
      case ReportStatusEnum.onScene:
        return AppColors.darkerGreen;
      case ReportStatusEnum.resolved:
        return AppColors.darkerGrey;
      default:
        return Colors.black;
    }
  }

  Color _getStatusBackgroundColor(ReportModel report) {
    switch (report.status) {
      case ReportStatusEnum.pending:
        return AppColors.lighterDeepOrange;
      case ReportStatusEnum.accepted:
        return AppColors.lighterBlue;
      case ReportStatusEnum.dispatched:
        return AppColors.lighterPurple;
      case ReportStatusEnum.onScene:
        return AppColors.lighterGreen;
      case ReportStatusEnum.resolved:
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

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
                      child: LabelText(
                        value: "No reports yet.",
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return ReportCard(
                        referenceNumber: report.referenceNumber,
                        emergencyType: report.incidentType!.name,
                        createdAt: DateFormat("MMM dd, yyyy • h:mm a").format(report.createdAt!),
                        status: report.status!,
                        statusColor: _getStatusColor(report),
                        statusBackground: _getStatusBackgroundColor(report),
                        report: report,
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
