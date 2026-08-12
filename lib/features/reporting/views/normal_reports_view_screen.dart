import 'package:capstone/core/shared/classes/formatter.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/text/data_label_text.dart';
import 'package:capstone/core/shared/widgets/text/data_value_text.dart';
import 'package:capstone/core/shared/widgets/text/paragraph_text.dart';
import 'package:capstone/features/reporting/models/report_model.dart';
import 'package:capstone/features/reporting/widgets/additional_information_card.dart';
import 'package:capstone/features/reporting/widgets/attachments_card.dart';
import 'package:capstone/features/reporting/widgets/location_card.dart';
import 'package:capstone/features/reporting/widgets/report_status_widget.dart';
import 'package:capstone/features/reporting/widgets/section_title.dart';
import 'package:capstone/features/reporting/widgets/victims_card.dart';
import 'package:flutter/material.dart';

class NormalReportsViewScreen extends StatelessWidget {
  const NormalReportsViewScreen({
    super.key,
    required this.report,
  });

  final ReportModel report;

  @override
  Widget build(BuildContext context) {
    final status = report.status!.name;
    final location = report.location;
    final information = report.additionalInformation.trim();
    return Scaffold(
      appBar: const CustomAppBar(value: "View Report"),
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
                                  const DataLabelText(
                                    value: 'EMERGENCY TYPE',
                                  ),
                                  DataValueText(
                                    value: Formatter.formatEnumName(report.incidentType!.name),
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
                        const DataLabelText(
                          value: 'DESCRIPTION',
                        ),
                        ParagraphText(
                          value: report.description.isEmpty ? 'No description provided.' : report.description,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SectionTitle(
                  icon: Icons.location_on_outlined,
                  title: 'Incident Location',
                ),
                const SizedBox(height: 10),
                LocationCard(location: location!),
                const SizedBox(height: 10),
                SectionTitle(
                  icon: Icons.people_outline,
                  title: 'Victims',
                ),
                const SizedBox(height: 10),
                VictimsCard(
                  victims: report.victims,
                ),
                const SizedBox(height: 10),
                SectionTitle(
                  icon: Icons.attach_file,
                  title: 'Attachments',
                ),
                const SizedBox(height: 10),
                AttachmentsCard(
                  attachments: report.attachments,
                ),
                const SizedBox(height: 10),
                SectionTitle(
                  icon: Icons.notes,
                  title: 'Additional Information',
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
