import 'package:capstone/core/l10n/enum_labels.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/models/response_model.dart';
import 'package:capstone/core/shared/providers/report_repository_provider.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/features/public_user/reporting/widgets/additional_information_card.dart';
import 'package:capstone/features/public_user/reporting/widgets/attachments_card.dart';
import 'package:capstone/features/public_user/reporting/widgets/location_card.dart';
import 'package:capstone/features/public_user/reporting/widgets/report_status_widget.dart';
import 'package:capstone/features/public_user/reporting/widgets/reporting_timeline_card.dart';
import 'package:capstone/features/public_user/reporting/widgets/victims_card.dart';
import 'package:capstone/features/responder/active_case/widgets/responder_notes_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryCaseDetailScreen extends ConsumerWidget {
  const HistoryCaseDetailScreen({super.key, required this.response});

  final ResponseModel response;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final report = ref.watch(reportByIdProvider(response.reportID)).value;
    if (report == null) {
      return Scaffold(
        appBar: CustomAppBar(value: l10n.caseDetails),
        body: const Center(child: CustomCircularProgressIndicator()),
      );
    }
    final location = report.location;

    return Scaffold(
      appBar: CustomAppBar(value: l10n.caseDetails),
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
                      LabelText(value: l10n.emergencyType.toUpperCase()),
                      BodyText(
                        value: report.incidentType?.label(l10n) ?? '—',
                        isBold: true,
                      ),
                      const SizedBox(height: 10),
                      ReportStatusWidget(status: response.status.name),
                      const SizedBox(height: 10),
                      LabelText(value: l10n.referenceNumber.toUpperCase()),
                      BodyText(value: report.referenceNumber, isBold: true),
                      const SizedBox(height: 10),
                      LabelText(value: l10n.description.toUpperCase()),
                      BodyText(
                        value: report.description.isEmpty ? l10n.noDescriptionProvided : report.description,
                      ),
                    ],
                  ),
                ),
              ),
                            const SizedBox(height: 10),
              SectionTitle(icon: Icons.timeline, title: l10n.statusTimeline),
              const SizedBox(height: 10),
              ReportTimelineCard(createdAt: report.createdAt, response: response),
              if (location != null) ...[
                const SizedBox(height: 10),
                SectionTitle(icon: Icons.location_on_outlined, title: l10n.incidentLocation),
                const SizedBox(height: 10),
                LocationCard(location: location),
              ],
              const SizedBox(height: 10),
              SectionTitle(icon: Icons.people_outline, title: l10n.victims),
              const SizedBox(height: 10),
              VictimsCard(victims: report.victims),
              const SizedBox(height: 10),
              SectionTitle(icon: Icons.attach_file, title: l10n.attachments),
              const SizedBox(height: 10),
              AttachmentsCard(attachments: report.attachments),
              if (response.responderAttachments.isNotEmpty) ...[
                const SizedBox(height: 10),
                SectionTitle(icon: Icons.add_a_photo_outlined, title: l10n.responderAttachments),
                const SizedBox(height: 10),
                AttachmentsCard(attachments: response.responderAttachments),
              ],
              const SizedBox(height: 10),
              SectionTitle(icon: Icons.notes, title: l10n.additionalInformation),
              const SizedBox(height: 10),
              AdditionalInformationCard(additionalInfo: report.additionalInformation.trim()),
              if (response.responderNotes.isNotEmpty) ...[
                const SizedBox(height: 10),
                SectionTitle(icon: Icons.edit_note, title: l10n.responderNotes),
                const SizedBox(height: 10),
                ResponderNotesCard(notes: response.responderNotes),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
