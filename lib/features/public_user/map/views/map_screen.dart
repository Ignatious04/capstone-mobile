import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/enums/map_mode_enum.dart';
import 'package:capstone/core/shared/providers/location_provider.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/public_user/map/providers/filtered_emergency_service_provider.dart';
import 'package:capstone/features/public_user/map/widgets/emergency_services_panel.dart';
import 'package:capstone/features/public_user/map/widgets/map_layer_button.dart';
import 'package:capstone/features/public_user/map/widgets/map_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;

  Widget _buildLocationError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 50,
              color: AppColors.blackTextMuted,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.locationUnavailableMsg,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.blackTextMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locationAsync = ref.watch(locationStreamProvider);
    final latLng = locationAsync.value;

    if (latLng == null) {
      return Scaffold(
        backgroundColor: AppColors.bgWhite,
        body: SafeArea(
          child: locationAsync.hasError
              ? _buildLocationError(locationAsync.error!)
              : const Center(child: CustomCircularProgressIndicator()),
        ),
      );
    }

    final servicesAsync = ref.watch(filteredEmergencyServicesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SafeArea(
        child: servicesAsync.when(
          data: (services) {
            return Stack(
              children: [
                Positioned.fill(
                  child: MapTileWidget(
                    initialLocation: latLng,
                    services: services,
                    mode: MapModeEnum.explore,
                    showLayerToggle: false, // placed below, clear of the header
                    onMapCreated: (controller) {
                      setState(() {
                        _mapController = controller;
                      });
                    },
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: CustomHeaderWidget(
                    title: l10n.serviceMap,
                    body: l10n.findNearbyServices,
                  ),
                ),
                 const Positioned(
                  right: 20,
                  bottom: 185,
                  child: MapLayerButton(),
                ),
                Positioned(
                  right: 20,
                  bottom: 125,
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.bgWhiteLight,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        _mapController?.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: latLng,
                              zoom: 15,
                            ),
                          ),
                        );
                      },
                      child: const SizedBox(
                        width: 50,
                        height: 50,
                        child: Icon(
                          Icons.my_location,
                          color: AppColors.themeColor,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_mapController != null)
                  EmergencyServicesPanel(
                    currentLocation: latLng,
                    services: services,
                    mapController: _mapController!,
                  ),
              ],
            );
          },
          loading: () => const Center(
            child: CustomCircularProgressIndicator(),
          ),
          error: (error, stackTrace) => Center(
            child: Text(error.toString()),
          ),
        ),
      ),
    );
  }
}