import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/core/utilities/formatter.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/info_column.dart';
import 'package:capstone/core/shared/models/report_model.dart';
import 'package:capstone/features/public_user/reporting/widgets/report_status_widget.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PreCallGuidanceReportViewScreen extends StatelessWidget {
  const PreCallGuidanceReportViewScreen({
    super.key,
    required this.report,
  });

  final ReportModel report;

  @override
  Widget build(BuildContext context) {
    final status = report.status!.name;
    // final location = report.location;
    // final information = report.additionalInformation.trim();
    return Scaffold(
      appBar: const CustomAppBar(value: "View Report"),
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
                                const BodyText(
                                  value: 'EMERGENCY TYPE',
                                ),
                                BodyText(
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
                        child: const TitleText(
                          value: "Pre-Call Guidance",
                        ),
                      ),
                      const SizedBox(height: 10),
                      const BodyText(
                        value: "This report was submitted through the pre-call guidance module.",
                        alignment: TextAlign.center,
                        isOverflow: false,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SectionTitle(
                icon: Icons.info,
                title: 'Incident Information',
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
                        title: "REFERENCE NUMBER",
                        value: report.referenceNumber,
                      ),
                      const SizedBox(height: 10),
                      InfoColumn(
                        title: "STATUS",
                        value: Formatter.formatEnumName(report.status!.name),
                      ),
                      const SizedBox(height: 10),
                      InfoColumn(
                        title: "INCIDENT TYPE",
                        value: Formatter.formatEnumName(report.incidentType!.name),
                      ),
                      const SizedBox(height: 10),
                      InfoColumn(
                        title: "SUBMITTED",
                        value: report.createdAt != null
                            ? DateFormat(
                                "MMMM dd, yyyy • hh:mm a",
                              ).format(report.createdAt!)
                            : "-",
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SectionTitle(
                icon: Icons.question_answer,
                title: "Questions and Answers",
              ),
              const SizedBox(height: 10),
              Card(
                color: Colors.white,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: report.guidanceAnswers.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final item = report.guidanceAnswers[index];
                    return ListTile(
                      title: BodyText(
                        value: item.question,
                      ),
                      subtitle: BodyText(
                        value: item.answer == null
                            ? "Not answered"
                            : item.answer!
                            ? "Yes"
                            : "No",
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
