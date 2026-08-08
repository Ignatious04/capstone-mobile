import 'dart:math';
import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/enums/report_type_enum.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/location_provider.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar.dart';
import 'package:capstone/core/shared/widgets/text/card_title_text.dart';
import 'package:capstone/core/shared/widgets/text/data_label_text.dart';
import 'package:capstone/core/shared/widgets/text/data_value_text.dart';
import 'package:capstone/core/shared/widgets/text/paragraph_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/pre_call_guidance/providers/guidance_provider.dart';
import 'package:capstone/features/reporting/providers/report_provider.dart';
import 'package:capstone/features/reporting/providers/report_repository_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreCallGuidanceSummaryScreen extends ConsumerWidget {
  const PreCallGuidanceSummaryScreen({super.key, required this.pageController, required this.onCancel});

  final PageController pageController;
  final VoidCallback onCancel;
  static const size = 25.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(guidanceProvider);
    final location = ref.watch(locationStreamProvider);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 20,
          ),
          Card(
            color: Colors.white,
            elevation: 1,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 50,
                  ),
                  const SizedBox(height: 10),
                  CardTitleText(
                    value: "Guidance Complete",
                    isBold: true,
                  ),
                  ParagraphText(
                    value:
                        "Your pre-call guidance has been completed. You may now submit your report to the appropriate agency.",
                    alignment: TextAlign.center,
                    isBold: false,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Card(
            color: Colors.white,
            elevation: 1,
            margin: EdgeInsets.zero,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.questions.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, index) {
                final item = state.questions[index];
                return ListTile(
                  title: DataLabelText(
                    value: item.question,
                  ),
                  subtitle: DataValueText(
                    value: item.answer == null
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
          const SizedBox(height: 10),
          CustomElevatedButton(
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

              if (context.mounted) {
                Navigator.pop(context);
              }

              ref.read(guidanceProvider.notifier).resetAnswers();
            },
            value: "Submit Report",
            color: Colors.white,
            backgroundColor: Colors.deepOrange,
          ),
          CustomElevatedButton(
            onPressed: onCancel,
            value: "Cancel",
            color: Colors.white,
            backgroundColor: AppColors.darkerGrey,
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
