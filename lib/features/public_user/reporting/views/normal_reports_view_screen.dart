import 'package:capstone/core/l10n/enum_labels.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/shared/providers/report_repository_provider.dart';
import 'package:capstone/core/shared/widgets/emergency_guidance_sheet.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/models/report_model.dart';
import 'package:capstone/features/public_user/reporting/widgets/additional_information_card.dart';
import 'package:capstone/features/public_user/reporting/widgets/attachments_card.dart';
import 'package:capstone/features/public_user/reporting/widgets/report_status_widget.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:capstone/features/public_user/reporting/widgets/report_responses_section.dart';
import 'package:capstone/features/public_user/reporting/widgets/victims_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NormalReportsViewScreen extends ConsumerStatefulWidget {
  const NormalReportsViewScreen({
    super.key,
    required this.report,
  });

  final ReportModel report;

  @override
  ConsumerState<NormalReportsViewScreen> createState() => _NormalReportsViewScreenState();
}

class _NormalReportsViewScreenState extends ConsumerState<NormalReportsViewScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Live copy of the report; falls back to the one passed in while loading/on error.
    final reportAsync = ref.watch(reportByIdProvider(widget.report.reportID));
    final deleted = reportAsync.hasValue && reportAsync.value == null;
    if (deleted) {
      return Scaffold(
        appBar: CustomAppBar(value: l10n.viewReport),
        body: const Center(child: Text('This report is no longer available.')),
      );
    }
    final report = reportAsync.value ?? widget.report;

    final status = report.status!.name;
    final information = report.additionalInformation.trim();
    final showGuidanceEntry = !(report.incidentType == ServiceTypeEnum.police && report.policeConcernType != null);

    return Scaffold(
      appBar: CustomAppBar(
        value: l10n.viewReport,
        actions: showGuidanceEntry
            ? [
                IconButton(
                  icon: const Icon(
                    Icons.info_outline,
                    size: 25,
                  ),
                  tooltip: l10n.whileYouWait,
                  onPressed: () => EmergencyGuidanceSheet.show(context, report.incidentType!),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
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
                                    value: l10n.incidentType.toUpperCase(),
                                  ),
                                  BodyText(
                                    value: report.incidentType!.label(l10n),
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
                          resolvedAt: report.resolvedAt,
                        ),
                        const SizedBox(height: 10),
                        LabelText(
                          value: l10n.description.toUpperCase(),
                        ),
                        BodyText(
                          value: report.description.isEmpty ? l10n.noDescriptionProvided : report.description,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ReportResponsesSection(report: report),
                const SizedBox(height: 10),
                SectionTitle(
                  icon: Icons.people_outline,
                  title: l10n.victims,
                ),
                const SizedBox(height: 10),
                VictimsCard(
                  victims: report.victims,
                ),
                const SizedBox(height: 10),
                SectionTitle(
                  icon: Icons.attach_file,
                  title: l10n.attachments,
                ),
                const SizedBox(height: 10),
                AttachmentsCard(
                  attachments: report.attachments,
                ),
                const SizedBox(height: 10),
                SectionTitle(
                  icon: Icons.notes,
                  title: l10n.additionalInformation,
                ),
                const SizedBox(height: 10),
                AdditionalInformationCard(
                  additionalInfo: information,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
