import 'package:capstone/core/shared/widgets/info_column.dart';
import 'package:capstone/core/shared/widgets/text/deprecated/text_body_medium.dart';
import 'package:capstone/core/shared/widgets/text/deprecated/text_title_medium.dart';
import 'package:capstone/core/shared/widgets/text/deprecated/text_title_small.dart';
import 'package:capstone/features/reporting/models/report_model.dart';
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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        title: const TextTitleSmall(
          title: "Back",
          color: Colors.white,
        ),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.assignment_turned_in,
                        color: Colors.green,
                        size: 50,
                      ),
                      const SizedBox(height: 10),
                      const TextTitleMedium(
                        title: "Pre-Call Guidance",
                        isBold: true,
                      ),
                      const SizedBox(height: 10),
                      const TextBodyMedium(
                        title: "This report was submitted through the pre-call guidance module.",
                        alignment: TextAlign.center,
                        isBold: false,
                      ),
                    ],
                  ),
                ),
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
                        title: "Reference Number",
                        value: report.referenceNumber,
                      ),
                      const SizedBox(height: 10),
                      InfoColumn(
                        title: "Status",
                        value: report.status?.name.toUpperCase() ?? "-",
                      ),
                      const SizedBox(height: 10),
                      InfoColumn(
                        title: "Incident Type",
                        value: report.incidentType?.name ?? "-",
                      ),
                      const SizedBox(height: 10),
                      InfoColumn(
                        title: "Submitted",
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
              const TextTitleSmall(
                title: "Questions & Answers",
                isBold: true,
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
                      title: TextBodyMedium(
                        title: item.question,
                        isBold: false,
                      ),
                      subtitle: TextTitleMedium(
                        title: item.answer == null
                            ? "Not answered"
                            : item.answer!
                            ? "Yes"
                            : "No",
                        isBold: false,
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
