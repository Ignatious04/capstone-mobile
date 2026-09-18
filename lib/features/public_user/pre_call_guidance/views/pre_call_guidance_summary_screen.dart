import 'package:capstone/core/shared/providers/location_provider.dart';
import 'package:capstone/core/shared/widgets/custom_alert_dialog.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/text/card_title_text.dart';
import 'package:capstone/core/shared/widgets/text/data_label_text.dart';
import 'package:capstone/core/shared/widgets/text/data_value_text.dart';
import 'package:capstone/core/shared/widgets/text/paragraph_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/public_user/pre_call_guidance/providers/guidance_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
    final location = ref.watch(currentLocationProvider);
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
          if (location.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  ParagraphText(value: "Getting your location..."),
                ],
              ),
            ),
          CustomElevatedButton(
            onPressed: location.isLoading
                ? null
                : () async {
                    final confirmed = await showConfirmationDialog(
                      context,
                      title: "Do you wish to submit this report?",
                    );

                    if (confirmed != true) {
                      return;
                    }

                    final currentLocation = location.value;

                    if (!context.mounted) {
                      return;
                    }

                    if (currentLocation == null) {
                      CustomSnackbarHelper.show(
                        context,
                        text: "Location unavailable!",
                      );
                      return;
                    }

                    final connectivityResult = await Connectivity().checkConnectivity();
                    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

                    if (!isOnline) {
                      if (!context.mounted) {
                        return;
                      }

                      final confirmed = await showConfirmationDialog(
                        context,
                        title:
                            "Due to the loss of internet connection, this report will send through the SMS, proceed?",
                      );

                      if (confirmed != true) {
                        return;
                      }
                    }

                    try {
                      final isSMS = await ref
                          .read(guidanceProvider.notifier)
                          .submitGuidanceReport(
                            location: currentLocation,
                            isOnline: isOnline,
                          );

                      if (context.mounted) {
                        Navigator.pop(context);

                        if (!isSMS) {
                          CustomSnackbarHelper.show(
                            context,
                            text: "Guidance report submitted successfully!",
                          );
                        }
                      }
                    } catch (e) {
                      debugPrint("ERROR: $e");
                      if (!context.mounted) {
                        return;
                      }
                      CustomSnackbarHelper.show(
                        context,
                        text: "An error has occurred while trying to send your report!",
                      );
                    }
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
