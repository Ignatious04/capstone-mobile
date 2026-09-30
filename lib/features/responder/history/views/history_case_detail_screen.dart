import 'package:capstone/core/shared/models/report_model.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/utilities/formatter.dart';
import 'package:capstone/features/public_user/reporting/widgets/additional_information_card.dart';
import 'package:capstone/features/public_user/reporting/widgets/attachments_card.dart';
import 'package:capstone/features/public_user/reporting/widgets/location_card.dart';
import 'package:capstone/features/public_user/reporting/widgets/report_status_widget.dart';
import 'package:capstone/features/public_user/reporting/widgets/victims_card.dart';
import 'package:flutter/material.dart';

class HistoryCaseDetailScreen extends StatelessWidget {
  const HistoryCaseDetailScreen({super.key, required this.report});

  final ReportModel report;

  @override
  Widget build(BuildContext context) {
    final location = report.location;
    final createdAt = report.createdAt;
    final resolvedAt = report.resolvedAt;

    return Scaffold(
      appBar: const CustomAppBar(value: 'Case Details'),
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
                      const LabelText(value: 'EMERGENCY TYPE'),
                      BodyText(
                        value: Formatter.formatEnumName(report.incidentType?.name ?? '—'),
                        isBold: true,
                      ),
                      const SizedBox(height: 10),
                      ReportStatusWidget(status: report.status?.name ?? 'resolved'),
                      const SizedBox(height: 10),
                      const LabelText(value: 'REFERENCE NUMBER'),
                      BodyText(value: report.referenceNumber, isBold: true),
                      if (createdAt != null) ...[
                        const SizedBox(height: 10),
                        const LabelText(value: 'REPORTED'),
                        BodyText(value: Formatter.formatDateTime(createdAt)),
                      ],
                      if (resolvedAt != null) ...[
                        const SizedBox(height: 10),
                        const LabelText(value: 'RESOLVED'),
                        BodyText(value: Formatter.formatDateTime(resolvedAt)),
                      ],
                      const SizedBox(height: 10),
                      const LabelText(value: 'DESCRIPTION'),
                      BodyText(
                        value: report.description.isEmpty ? 'No description provided.' : report.description,
                      ),
                    ],
                  ),
                ),
              ),
              if (location != null) ...[
                const SizedBox(height: 10),
                SectionTitle(icon: Icons.location_on_outlined, title: 'Incident Location'),
                const SizedBox(height: 10),
                LocationCard(location: location),
              ],
              const SizedBox(height: 10),
              SectionTitle(icon: Icons.people_outline, title: 'Victims'),
              const SizedBox(height: 10),
              VictimsCard(victims: report.victims),
              const SizedBox(height: 10),
              SectionTitle(icon: Icons.attach_file, title: 'Attachments'),
              const SizedBox(height: 10),
              AttachmentsCard(attachments: report.attachments),
              const SizedBox(height: 10),
              SectionTitle(icon: Icons.notes, title: 'Additional Information'),
              const SizedBox(height: 10),
              AdditionalInformationCard(additionalInfo: report.additionalInformation.trim()),
            ],
          ),
        ),
      ),
    );
  }
}
