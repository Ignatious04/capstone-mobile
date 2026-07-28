import 'package:capstone/core/shared/widgets/text/text_body_medium.dart';
import 'package:capstone/core/shared/widgets/text/text_body_small.dart';
import 'package:capstone/features/reporting/models/report_model.dart';
import 'package:capstone/features/reporting/views/reports_view_screen.dart';
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
                      TextBodyMedium(title: referenceNumber.toString()),
                      TextBodySmall(title: "Emergency Type: $emergencyType"),
                      TextBodySmall(title: createdAt),
                      TextBodySmall(title: "Status: $status"),
                    ],
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  width: 1,
                  color: Colors.black,
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ReportsViewScreen(report: report);
                        },
                      ),
                    );
                  },
                  child: Icon(Icons.arrow_right, size: 50, color: Colors.deepOrange,),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
