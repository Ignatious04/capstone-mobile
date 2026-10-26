import 'package:capstone/core/l10n/enum_labels.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/providers/report_repository_provider.dart';
import 'package:capstone/core/shared/widgets/emergency_guidance_sheet.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/info_column.dart';
import 'package:capstone/core/shared/models/report_model.dart';
import 'package:capstone/features/public_user/reporting/widgets/report_status_widget.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:capstone/features/public_user/reporting/widgets/report_responses_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PreCallGuidanceReportViewScreen extends ConsumerWidget {
  const PreCallGuidanceReportViewScreen({
    super.key,
    required this.report,
  });

  final ReportModel report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final reportAsync = ref.watch(reportByIdProvider(report.reportID));
    final deleted = reportAsync.hasValue && reportAsync.value == null;

    if (deleted) {
      return Scaffold(
        appBar: CustomAppBar(value: l10n.viewReport),
        body: const Center(child: Text('This report is no longer available.')),
      );
    }
    final currentReport = reportAsync.value ?? report;

    final status = currentReport.status!.name;
    return Scaffold(
      appBar: CustomAppBar(
        value: l10n.viewReport,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: l10n.whileYouWait,
            onPressed: () => EmergencyGuidanceSheet.show(context, currentReport.incidentType!),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.white,
                elevation: 1,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.deepOrange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.emergency_outlined,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BodyText(
                                  value: l10n.emergencyType.toUpperCase(),
                                ),
                                BodyText(
                                  value: currentReport.incidentType!.label(l10n),
                                  isBold: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ReportStatusWidget(
                        status: status,
                      ),
                      const SizedBox(height: 10),
                      Divider(
                        height: 1,
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.assignment_turned_in,
                          color: Colors.green,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.center,
                        child: TitleText(
                          value: l10n.preCallGuidance,
                        ),
                      ),
                      const SizedBox(height: 10),
                      BodyText(
                        value: l10n.preCallReportNote,
                        alignment: TextAlign.center,
                        isOverflow: false,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ReportResponsesSection(report: currentReport),
              const SizedBox(height: 10),
              SectionTitle(
                icon: Icons.info,
                title: l10n.incidentInformation,
              ),
              const SizedBox(height: 10),
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoColumn(
                        title: l10n.referenceNumber.toUpperCase(),
                        value: currentReport.referenceNumber,
                      ),
                      const SizedBox(height: 10),
                      InfoColumn(
                        title: l10n.submitted.toUpperCase(),
                        value: currentReport.createdAt != null
                            ? DateFormat(
                                "MMMM dd, yyyy • hh:mm a",
                                Localizations.localeOf(context).toString(),
                              ).format(currentReport.createdAt!)
                            : "-",
                      ),
                      if (currentReport.locationDescription?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 10),
                        InfoColumn(
                          title: l10n.landmarkLabel.toUpperCase(),
                          value: currentReport.locationDescription!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SectionTitle(
                icon: Icons.question_answer,
                title: l10n.questionsAndAnswers,
              ),
              const SizedBox(height: 10),
              Card(
                color: Colors.white,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: currentReport.guidanceAnswers.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final item = currentReport.guidanceAnswers[index];
                    return ListTile(
                      title: BodyText(
                        value: item.localizedQuestion(l10n),
                      ),
                      subtitle: BodyText(
                        value: item.answer == null
                            ? l10n.notAnswered
                            : item.answer!
                            ? l10n.yes
                            : l10n.no,
                        isBold: true,
                      ),
                      leading: Icon(
                        item.answer == true ? Icons.check_circle : Icons.cancel,
                        color: item.answer == true ? Colors.green : Colors.red,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
