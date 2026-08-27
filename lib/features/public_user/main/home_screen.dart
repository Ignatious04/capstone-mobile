import 'package:capstone/core/enums/map_mode_enum.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/shared/providers/location_provider.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/text/button_text.dart';
import 'package:capstone/core/shared/widgets/text/section_title_text.dart';
import 'package:capstone/core/shared/widgets/service_button.dart';
import 'package:capstone/core/utilities/distance_helper.dart';
import 'package:capstone/features/public_user/main/providers/nearest_emergency_services_provider.dart';
import 'package:capstone/features/public_user/map/widgets/map_tile_widget.dart';
import 'package:capstone/core/shared/widgets/nearby_services.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/public_user/reporting/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool showOptions = false;
  String address = "Brgy. Balibago, Angeles City";
  double radius = 12;

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationStreamProvider);
    final nearestServicesAsync = ref.watch(nearestEmergencyServicesProvider);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.deepOrange,
              child: Row(
                children: [
                  Expanded(
                    child: CustomHeaderWidget(
                      title: "MEAS",
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.notifications),
                      style: IconButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
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
                          onPressed: () {},
                          value: "Fire",
                          icon: Icons.fire_truck,
                          color: Colors.red,
                          backgroundColor: AppColors.lighterRed,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ServiceButton(
                          onPressed: () {},
                          value: "Crime",
                          icon: Icons.local_police,
                          color: Colors.blue,
                          backgroundColor: AppColors.lighterBlue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ServiceButton(
                          onPressed: () {},
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
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const SectionTitleText(
                        value: "OR",
                        color: AppColors.lighterBlack,
                        isBold: false,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Expanded(
                        child: Divider(
                          height: 1,
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
                      onPressed: () {},
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
                            size: 30,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ButtonText(
                            value: "CALL 911",
                            color: Colors.white,
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
                              NearbyServices(
                                name: service.name,
                                address: service.address,
                                distance: distanceMeters / 1000,
                              ),
                              const SizedBox(height: 10),
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
          ],
        ),
      ),
    );
  }
}
