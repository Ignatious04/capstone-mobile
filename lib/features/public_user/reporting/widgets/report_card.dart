import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/enums/report_type_enum.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/core/utilities/formatter.dart';
import 'package:capstone/core/shared/models/report_model.dart';
import 'package:capstone/features/public_user/reporting/views/pre_call_guidance_report_view_screen.dart';
import 'package:capstone/features/public_user/reporting/views/normal_reports_view_screen.dart';
import 'package:flutter/material.dart';

class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.referenceNumber,
    required this.emergencyType,
    required this.createdAt,
    required this.status,
    required this.statusColor,
    required this.statusBackground,
    required this.report,
  });

  final String referenceNumber;
  final String emergencyType;
  final String createdAt;
  final ReportStatusEnum status;
  final Color statusColor;
  final Color statusBackground;
  final ReportModel report;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.lighterBlack,
        ),
      ),
      child: Container(
        width: double.infinity,
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
                      TitleText(
                        value: referenceNumber.toString(),
                      ),
                      BodyText(
                        value: "Emergency Type: ${Formatter.formatEnumName(emergencyType)}",
                      ),
                      BodyText(
                        value: createdAt,
                      ),
                      Row(
                        children: [
                          BodyText(
                            value: "Status: ",
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: statusBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: LabelText(
                              value: Formatter.formatEnumName(status.name),
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                VerticalDivider(
                  width: 1,
                  color: Colors.black54,
                ),
                SizedBox(
                  width: 10,
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      if (report.reportType == ReportTypeEnum.preCallGuidance) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PreCallGuidanceReportViewScreen(report: report),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NormalReportsViewScreen(report: report, ),
                          ),
                        );
                      }
                    },
                    child: const Icon(
                      Icons.arrow_right,
                      size: 50,
                      color: Colors.deepOrange,
                    ),
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
