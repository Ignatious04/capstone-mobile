import 'dart:async';
import 'package:capstone/core/l10n/enum_labels.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/enums/audit_action_enum.dart';
import 'package:capstone/core/enums/map_mode_enum.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/shared/providers/audit_log_repository_provider.dart';
import 'package:capstone/core/shared/providers/location_provider.dart';
import 'package:capstone/core/shared/providers/verification_provider.dart';
import 'package:capstone/core/shared/widgets/consent_banner.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/hold_service_button.dart';
import 'package:capstone/core/shared/widgets/loading_overlay_widget.dart';
import 'package:capstone/core/shared/widgets/offline_sms_banner.dart';
import 'package:capstone/core/shared/widgets/reporting_restriction_banner.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/shared/widgets/verification_banner.dart';
import 'package:capstone/core/utilities/call_launcher.dart';
import 'package:capstone/core/utilities/distance_helper.dart';
import 'package:capstone/core/utilities/submit_guard_mixin.dart';
import 'package:capstone/features/public_user/main/providers/nearest_emergency_services_provider.dart';
import 'package:capstone/features/public_user/map/models/emergency_service_model.dart';
import 'package:capstone/features/public_user/map/providers/contact_number_repository_provider.dart';
import 'package:capstone/features/public_user/map/widgets/map_tile_widget.dart';
import 'package:capstone/features/public_user/main/widgets/nearby_services_card.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/core/shared/providers/report_provider.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:capstone/features/public_user/notifications/widgets/notification_bell_button.dart';
import 'package:capstone/features/public_user/pre_call_guidance/utilities/offline_report_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SubmitGuardMixin<HomeScreen> {
  bool showOptions = false;
  double radius = 12;

  IconData _getServiceIcon(EmergencyServiceModel service) {
    switch (service.type) {
      case ServiceTypeEnum.fire:
        return Icons.local_fire_department_outlined;

      case ServiceTypeEnum.police:
        return Icons.local_police_outlined;

      case ServiceTypeEnum.medical:
        return Icons.local_hospital_outlined;
    }
  }

  Color _getServiceColor(EmergencyServiceModel service) {
    switch (service.type) {
      case ServiceTypeEnum.fire:
        return Colors.red;

      case ServiceTypeEnum.police:
        return Colors.blue;

      case ServiceTypeEnum.medical:
        return Colors.green;
    }
  }

  Color _getServiceBackgroundColor(EmergencyServiceModel service) {
    switch (service.type) {
      case ServiceTypeEnum.fire:
        return AppColors.lighterRed;
      case ServiceTypeEnum.police:
        return AppColors.lighterBlue;
      case ServiceTypeEnum.medical:
        return AppColors.lighterGreen;
    }
  }

  Future<void> _submitQuickReport(ServiceTypeEnum incidentType) async {
    final l10n = AppLocalizations.of(context)!;

    // Offline: go to the SMS flow for this service instead of timing out.
    if (await handleOffline(context, ref, type: incidentType)) return;
    if (!mounted) return;

    if (!await ensureCanReport(context, ref)) return;
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingOverlayWidget(message: l10n.sendingQuickReport),
    );

    try {
      final fix = await ref.read(locationServiceProvider).getCurrentLocation();
      await ref
          .read(reportProvider.notifier)
          .submitQuickReport(
            incidentType: incidentType,
            location: fix.latLng,
            reportedForSelf: true,
          );

      if (!mounted) return;
      Navigator.pop(context);
      CustomSnackbarHelper.show(context, text: l10n.quickReportSuccess);
    } on TimeoutException {
      if (!mounted) return;
      Navigator.pop(context);
      if (!context.mounted) return;
      // connectivity_plus said online but the write never got through.
      if (await confirmSmsFallback(context)) {
        if (!mounted) return;
        startGuidanceFlow(context, ref, incidentType);
      } else if (mounted) {
        CustomSnackbarHelper.show(context, text: l10n.reportTimeoutError);
      }
    } catch (e, stack) {
      debugPrint("ERROR: $e");
      debugPrintStack(stackTrace: stack);
      if (!context.mounted) return;
      Navigator.pop(context);
      CustomSnackbarHelper.show(
        context,
        text: l10n.reportSendError,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final location = ref.watch(locationStreamProvider);
    final nearestServicesAsync = ref.watch(nearestEmergencyServicesProvider);

    ref.listen(nearestEmergencyServicesProvider, (previous, next) {
      next.whenData((nearest) {
        final prev = previous?.value; // use `.value` on Riverpod 3.x
        final changed = ServiceTypeEnum.values.any(
          (t) => prev?[t]?.contactNumber != nearest[t]?.contactNumber,
        );
        if (changed) {
          ref.read(contactNumberRepositoryProvider).saveNearest(nearest);
        }
      });
    });

    return SafeArea(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.themeColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomHeaderWidget(
                    title: "Saup Angeles",
                    hasBoxShadow: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const NotificationBellButton(),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                      left: 20.0,
                      right: 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Card(
                          color: AppColors.bgWhiteLight,
                          elevation: 1,
                          margin: EdgeInsets.zero,
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                            height: 250,
                            child: location.when(
                              data: (latLng) => MapTileWidget(
                                initialLocation: latLng,
                                mode: MapModeEnum.view,
                                followLocation: true,
                              ),
                              loading: () => const Center(
                                child: CustomCircularProgressIndicator(),
                              ),
                              error: (e, _) => Text(e.toString()),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const ConsentBanner(),
                        const OfflineSmsBanner(),
                        const VerificationBanner(),
                        const ReportingRestrictionBanner(),
                        SectionTitle(
                          icon: Icons.select_all,
                          title: l10n.quickReporting,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: HoldServiceButton(
                                enabled: !isBusy,
                                onHoldComplete: () => guarded(() => _submitQuickReport(ServiceTypeEnum.fire)),
                                value: ServiceTypeEnum.fire.label(l10n),
                                icon: Icons.fire_truck,
                                color: Colors.red,
                                backgroundColor: AppColors.lighterRed,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                               child: HoldServiceButton(
                                enabled: !isBusy,
                                onHoldComplete: () => guarded(() => _submitQuickReport(ServiceTypeEnum.police)),
                                value: l10n.quickCrime,
                                icon: Icons.local_police,
                                color: Colors.blue,
                                backgroundColor: AppColors.lighterBlue,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: HoldServiceButton(
                                enabled: !isBusy,
                                onHoldComplete: () => guarded(() => _submitQuickReport(ServiceTypeEnum.medical)),
                                value: ServiceTypeEnum.medical.label(l10n),
                                icon: Icons.medical_services,
                                color: Colors.green,
                                backgroundColor: AppColors.lighterGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: LabelText(
                            value: l10n.holdToReport,
                            color: AppColors.blackTextMuted,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                         ),
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                height: 10,
                                color: AppColors.blackTextMuted,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            BodyText(
                              value: l10n.or.toUpperCase(),
                              color: AppColors.blackTextMuted,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Expanded(
                              child: Divider(
                                height: 10,
                                color: AppColors.blackTextMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(auditLogRepositoryProvider)
                                  .log(
                                    AuditAction.emergencyCallInitiated,
                                    metadata: {'source': 'home_911'},
                                  );
                              launchPhoneCall("*123#");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.danger,
                              iconColor: AppColors.whiteTextFull,
                              fixedSize: const Size(95, 100),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(radius),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.call,
                                  size: 50,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                BodyText(
                                  value: l10n.call911Button,
                                  color: AppColors.whiteTextFull,
                                  isBold: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SectionTitle(
                          icon: Icons.miscellaneous_services,
                          title: l10n.nearbyServices,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  nearestServicesAsync.when(
                    data: (nearestByType) {
                      return Column(
                        children: ServiceTypeEnum.values.map((type) {
                          final service = nearestByType[type];

                          if (service == null) {
                            return const SizedBox.shrink();
                          }

                          final distanceMeters = DistanceHelper.distanceInMeters(
                            location.value!,
                            service.location,
                          );

                          return Column(
                            children: [
                              NearbyServicesCard(
                                icon: _getServiceIcon(service),
                                iconColor: _getServiceColor(service),
                                backgroundColor: _getServiceBackgroundColor(service),
                                name: service.name,
                                contactNumber: service.contactNumber,
                                address: service.address,
                                distanceMeters: distanceMeters,
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(child: CustomCircularProgressIndicator()),
                    error: (e, _) => Text(e.toString()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
