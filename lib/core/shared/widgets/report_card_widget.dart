import 'package:capstone/core/enums/report_type_enum.dart';
import 'package:capstone/core/shared/widgets/text/text_body_medium.dart';
import 'package:capstone/core/shared/widgets/text/text_body_small.dart';
import 'package:capstone/core/shared/widgets/text/text_title_medium.dart';
import 'package:capstone/core/shared/widgets/text/text_title_small.dart';
import 'package:capstone/features/reporting/models/report_model.dart';
import 'package:capstone/features/reporting/views/pre_call_guidance_report_view_screen.dart';
import 'package:capstone/features/reporting/views/normal_reports_view_screen.dart';
import 'package:flutter/material.dart';

class ReportCardWidget extends StatelessWidget {
  const ReportCardWidget({
    super.key,
    required this.referenceNumber,
    required this.emergencyType,
    required this.createdAt,
    required this.status,
    required this.report,
  });

  final String referenceNumber;
  final String emergencyType;
  final String createdAt;
  final String status;
  final ReportModel report;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextTitleMedium(
                        title: referenceNumber.toString(),
                        isBold: true,
                      ),
                      TextBodyMedium(
                        title: "Emergency Type: $emergencyType",
                        isBold: false,
                      ),
                      TextBodyMedium(title: createdAt, isBold: false),
                      TextBodyMedium(title: "Status: $status", isBold: false),
                    ],
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                VerticalDivider(
                  width: 1,
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    if (report.reportType == ReportTypeEnum.normal) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return NormalReportsViewScreen(report: report);
                          },
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return PreCallGuidanceReportViewScreen(report: report);
                          },
                        ),
                      );
                    }
                  },
                  child: Icon(
                    Icons.arrow_right,
                    size: 50,
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
