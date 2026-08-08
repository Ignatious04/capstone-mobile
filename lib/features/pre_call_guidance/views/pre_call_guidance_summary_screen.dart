import 'dart:math';
import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/enums/report_type_enum.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/location_provider.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar.dart';
import 'package:capstone/core/shared/widgets/text/deprecated/text_body_medium.dart';
import 'package:capstone/core/shared/widgets/text/deprecated/text_title_small.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/pre_call_guidance/providers/guidance_provider.dart';
import 'package:capstone/features/pre_call_guidance/widgets/pre_call_guidance_summary_card_widget.dart';
import 'package:capstone/features/reporting/providers/report_provider.dart';
import 'package:capstone/features/reporting/providers/report_repository_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreCallGuidanceSummaryScreen extends ConsumerWidget {
  const PreCallGuidanceSummaryScreen({super.key, required this.pageController});

  final PageController pageController;
  static const size = 25.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(guidanceProvider);
    final location = ref.watch(locationStreamProvider);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 64,
                        ),
                        const SizedBox(height: 10),
                        TextTitleSmall(
                          title: "Guidance Complete",
                          isBold: true,
                        ),
                        const SizedBox(height: 10),
                        TextBodyMedium(
                          title:
                              "Your emergency guidance has been completed."
                              "You may now submit your report to the appropriate agency.",
                          alignment: TextAlign.center,
                          isBold: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Card(
                color: Colors.white,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.questions.length,
                  itemBuilder: (_, index) {
                    final question = state.questions[index];

                    return PreCallGuidanceSummaryCardWidget(
                      question: question.question,
                      answer: question.answer.toString(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final reportID = ref.read(reportRepositoryProvider).getReportID();
                  final now = DateTime.now();
                  final date =
                      '${now.year}'
                      '${now.month.toString().padLeft(2, '0')}'
                      '${now.day.toString().padLeft(2, '0')}';

                  if (!location.hasValue) {
                    CustomSnackbar(text: "Unable to get your current location.");
                    return;
                  }

                  final currentLocation = location.value!;

                  final report = ref
                      .read(reportProvider)
                      .copyWith(
                        reportID: reportID,
                        referenceNumber: "RPT-$date-${Random().nextInt(900000) + 100000}",
                        userID: ref.read(firebaseAuthProvider).currentUser!.uid.toString(),
                        reportType: ReportTypeEnum.preCallGuidance,
                        guidanceAnswers: state.questions,
                        status: ReportStatusEnum.pending,
                        location: GeoPoint(
                          currentLocation.latitude,
                          currentLocation.longitude,
                        ),
                        createdAt: now,
                      );

                  await ref.read(reportRepositoryProvider).createReport(report);

                  ref.read(guidanceProvider.notifier).resetAnswers();

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Submit report",
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(guidanceProvider.notifier).resetAnswers();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lighterBlack,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Cancel",
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
