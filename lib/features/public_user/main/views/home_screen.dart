import 'package:capstone/core/enums/map_mode_enum.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/shared/providers/location_provider.dart';
import 'package:capstone/core/shared/providers/notification_history_provider.dart';
import 'package:capstone/core/shared/widgets/custom_alert_dialog.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/loading_overlay_widget.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/service_button.dart';
import 'package:capstone/core/utilities/call_launcher.dart';
import 'package:capstone/core/utilities/distance_helper.dart';
import 'package:capstone/core/utilities/formatter.dart';
import 'package:capstone/features/public_user/main/providers/nearest_emergency_services_provider.dart';
import 'package:capstone/features/public_user/map/models/emergency_service_model.dart';
import 'package:capstone/features/public_user/map/providers/contact_number_repository_provider.dart';
import 'package:capstone/features/public_user/map/widgets/map_tile_widget.dart';
import 'package:capstone/features/public_user/main/widgets/nearby_services_card.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/public_user/notifications/views/notification_history_screen.dart';
import 'package:capstone/features/public_user/reporting/providers/report_provider.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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

  Future<void> _submitQuickReport(ServiceTypeEnum incidentType) async {
    final label = Formatter.formatEnumName(incidentType.name);
    final location = ref.read(locationStreamProvider).value;

    if (location == null) {
      CustomSnackbarHelper.show(context, text: "Unable to get your current location.");
      return;
    }

    final confirmed = await showConfirmationDialog(
      context,
      title: "Send a $label report?",
      content:
          "This immediately sends $label your current location as an emergency report. "
          "Only use this for real emergencies.",
    );

    if (confirmed != true) return;
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingOverlayWidget(),
    );

    try {
      await ref
          .read(reportProvider.notifier)
          .submitQuickReport(
            incidentType: incidentType,
            location: location,
          );

      if (!mounted) return;
      Navigator.pop(context);
      CustomSnackbarHelper.show(context, text: "Report sent!");
    } catch (e, stack) {
      debugPrint("ERROR: $e");
      debugPrintStack(stackTrace: stack);
      if (!context.mounted) return;
      Navigator.pop(context);
      CustomSnackbarHelper.show(
        context,
        text: "An error has occurred while trying to send your report!",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationStreamProvider);
    final nearestServicesAsync = ref.watch(nearestEmergencyServicesProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    ref.listen(nearestEmergencyServicesProvider, (previous, next) {
      next.whenData((nearest) {
        ref.read(contactNumberRepositoryProvider).saveNearest(nearest);
      });
    });

    return SafeArea(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.deepOrange,
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
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificationHistoryScreen()),
                          );
                        },
                        icon: Icon(Icons.notifications),
                        style: IconButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: Text(
                              '$unreadCount',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ),
                    ],
                  ),
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
                          color: Colors.white,
                          elevation: 1,
                          margin: EdgeInsets.zero,
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                            height: 250,
                            child: location.when(
                              data: (latLng) => MapTileWidget(
                                initialLocation: latLng,
                                mode: MapModeEnum.view,
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
                        const SectionTitle(
                          icon: Icons.select_all,
                          title: "Select Emergency Type",
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ServiceButton(
                                onPressed: () => _submitQuickReport(ServiceTypeEnum.fire),
                                value: "Fire",
                                icon: Icons.fire_truck,
                                color: Colors.red,
                                backgroundColor: AppColors.lighterRed,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ServiceButton(
                                onPressed: () => _submitQuickReport(ServiceTypeEnum.police),
                                value: "Crime",
                                icon: Icons.local_police,
                                color: Colors.blue,
                                backgroundColor: AppColors.lighterBlue,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ServiceButton(
                                onPressed: () => _submitQuickReport(ServiceTypeEnum.medical),
                                value: "Medical",
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
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                height: 1,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const BodyText(
                              value: "OR",
                              color: Colors.black54,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Expanded(
                              child: Divider(
                                height: 1,
                                color: Colors.black54,
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
                              launchPhoneCall("*123#");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              iconColor: Colors.white,
                              fixedSize: const Size(95, 100),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(radius),
                              ),
                            ),
                            child: const Column(
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
                                  value: "CALL 911",
                                  color: Colors.white,
                                  isBold: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const SectionTitle(
                          icon: Icons.miscellaneous_services,
                          title: "Nearby Services",
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
                                name: service.name,
                                contactNumber: service.contactNumber,
                                address: service.address,
                                distance: distanceMeters / 1000,
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
