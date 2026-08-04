import 'package:capstone/core/enums/map_mode_enum.dart';
import 'package:capstone/core/shared/providers/location_provider.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/text/text_body_medium.dart';
import 'package:capstone/features/map/widgets/map_tile_widget.dart';
import 'package:capstone/core/shared/widgets/nearby_services.dart';
import 'package:capstone/core/shared/widgets/text/text_title_small.dart';
import 'package:capstone/core/themes/app_colors.dart';
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
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 250,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(radius),
                      child: location.when(
                        data: (latLng) => MapTileWidget(
                          initialLocation: latLng,
                          mode: MapModeEnum.view,
                        ),
                        loading: () => Center(child: const CustomCircularProgressIndicator()),
                        error: (e, _) => Text(e.toString()),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextTitleSmall(
                    title: "SELECT EMERGENCY TYPE",
                    isBold: true,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          iconColor: Colors.red,
                          backgroundColor: AppColors.lighterRed,
                          padding: EdgeInsets.all(0),
                          fixedSize: const Size(95, 100),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(radius),
                          ),
                          side: BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fire_truck),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Fire",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lighterBlue,
                          // backgroundColor: Colors.blue.withValues(
                          //   alpha: 0.2,
                          // ),
                          iconColor: Colors.blue,
                          padding: EdgeInsets.all(0),
                          fixedSize: const Size(95, 100),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(radius),
                          ),
                          side: BorderSide(
                            color: Colors.blue,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_police),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Crime",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lighterGreen,
                          iconColor: Colors.green,
                          padding: EdgeInsets.all(0),
                          fixedSize: const Size(95, 100),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(radius),
                          ),
                          side: BorderSide(
                            color: Colors.green,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.medical_services),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Medical",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.black.withValues(alpha: 0.2),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      TextBodyMedium(
                        title: "OR",
                        color: Colors.black.withValues(alpha: 0.2),
                        isBold: false,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.black.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        iconColor: Colors.white,
                        padding: EdgeInsets.all(0),
                        fixedSize: const Size(95, 100),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(radius),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.call),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "CALL 911",
                            style:
                                Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextTitleSmall(
                    title: "NEARBY SERVICES",
                    isBold: true,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ...List.generate(
                    3,
                    (index) {
                      return Column(
                        children: [
                          NearbyServices(
                            name: "Service name",
                            address: "Address",
                            distance: 0.0,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      );
                    },
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
