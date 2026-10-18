import 'package:capstone/core/l10n/enum_labels.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/providers/connectivity_stream_provider.dart';
import 'package:capstone/core/shared/providers/location_provider.dart';
import 'package:capstone/core/shared/providers/report_provider.dart';
import 'package:capstone/core/shared/providers/verification_provider.dart';
import 'package:capstone/core/shared/widgets/custom_alert_dialog.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/emergency_guidance_sheet.dart';
import 'package:capstone/core/shared/widgets/loading_overlay_widget.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/features/public_user/pre_call_guidance/providers/guidance_provider.dart';
import 'package:capstone/features/public_user/reporting/views/select_location_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PreCallGuidanceSummaryScreen extends ConsumerStatefulWidget {
  const PreCallGuidanceSummaryScreen({super.key, required this.pageController, required this.onCancel});

  final PageController pageController;
  final VoidCallback onCancel;

  @override
  ConsumerState<PreCallGuidanceSummaryScreen> createState() => _PreCallGuidanceSummaryScreenState();
}

class _PreCallGuidanceSummaryScreenState extends ConsumerState<PreCallGuidanceSummaryScreen> {
  final _noteController = TextEditingController();
  LatLng? _adjustedLocation;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final state = ref.watch(guidanceProvider);
    final location = ref.watch(currentLocationProvider);
    final isOnline = ref.watch(connectivityStreamProvider).value?.contains(ConnectivityResult.none) == false;
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
                  TitleText(
                    value: l10n.guidanceCompleteTitle,
                    isBold: true,
                  ),
                  BodyText(
                    value: l10n.guidanceCompleteBody,
                    alignment: TextAlign.center,
                    isOverflow: false,
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
                  title: BodyText(
                    value: item.localizedQuestion(l10n),
                  ),
                  subtitle: BodyText(
                    value: item.answer == null
                        ? l10n.notAnswered
                        : item.answer!
                        ? l10n.yes
                        : l10n.no,
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
          const SizedBox(height: 10),
          if (location.isLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 25,
                    width: 25,
                    child: CustomCircularProgressIndicator(color: Colors.deepOrange),
                  ),
                  SizedBox(width: 10),
                  BodyText(value: l10n.gettingLocation),
                ],
              ),
            ),
          if (location.hasValue) ...[
            if (location.value!.accuracy > 50)
              BodyText(
                value: l10n.weakGps(location.value!.accuracy.round()),
                alignment: TextAlign.center,
              ),
            TextField(
              controller: _noteController,
              maxLength: 80,
              style:
                  Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(
                    color: Colors.black,
                  ),
              decoration: InputDecoration(
                labelText: l10n.landmarkLabel,
                labelStyle:
                    Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
                hintText: l10n.landmarkHint,
                hintStyle:
                    Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
              ),
              onTapOutside: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
            ),
            if (isOnline)
              TextButton.icon(
                icon: const Icon(
                  Icons.edit_location_alt,
                  size: 25,
                  color: Colors.black54,
                ),
                label: BodyText(
                  value: _adjustedLocation == null ? l10n.adjustLocation : l10n.locationAdjusted,
                  color: Colors.black54,
                ),
                onPressed: () async {
                  final picked = await Navigator.push<LatLng>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SelectLocationScreen(
                        initialLocation: _adjustedLocation ?? location.value!.latLng,
                      ),
                    ),
                  );
                  if (picked != null && mounted) setState(() => _adjustedLocation = picked);
                },
              ),
          ],
          CustomElevatedButton(
            onPressed: location.isLoading
                ? null
                : () async {
                    final confirmed = await showConfirmationDialog(
                      context,
                      title: l10n.submitReportPrompt,
                      content: l10n.responseTimeNotice,
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
                        text: l10n.locationUnavailableBang,
                      );
                      return;
                    }

                    final connectivityResult = await Connectivity().checkConnectivity();
                    final isOnlineNow = !connectivityResult.contains(ConnectivityResult.none);

                    if (!context.mounted) return;
                    if (isOnlineNow && !await ensureVerified(context, ref)) return;

                    if (!isOnlineNow) {
                      if (!context.mounted) {
                        return;
                      }

                      final confirmed = await showConfirmationDialog(
                        context,
                        title: l10n.offlineSmsPrompt,
                      );

                      if (confirmed != true) {
                        return;
                      }
                    }

                    if (!context.mounted) {
                      return;
                    }

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const LoadingOverlayWidget(),
                    );

                    try {
                      final fix = location.value!;

                      final isSMS = await ref
                          .read(guidanceProvider.notifier)
                          .submitGuidanceReport(
                            location: _adjustedLocation ?? fix.latLng,
                            originalGPS: _adjustedLocation != null ? fix.latLng : null,
                            accuracy: fix.accuracy,
                            locationNote: _noteController.text.trim(),
                            isOnline: isOnlineNow,
                          );

                      if (context.mounted) {
                        Navigator.pop(context);

                        final incidentType = ref.read(reportProvider).incidentType!;

                        await EmergencyGuidanceSheet.show(context, incidentType);

                        if (!context.mounted) {
                          return;
                        }

                        Navigator.pop(context);

                        if (!isSMS) {
                          CustomSnackbarHelper.show(
                            context,
                            text: l10n.guidanceSubmitted,
                          );
                        }
                      }
                    } catch (e) {
                      debugPrint("ERROR: $e");
                      if (!context.mounted) {
                        return;
                      }

                      Navigator.pop(context);

                      CustomSnackbarHelper.show(
                        context,
                        text: l10n.reportSendError,
                      );
                    }
                  },
            value: l10n.submitReport,
            color: Colors.white,
            backgroundColor: Colors.deepOrange,
          ),
          CustomElevatedButton(
            onPressed: widget.onCancel,
            value: l10n.cancel,
            color: Colors.white,
            backgroundColor: Colors.black54,
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
