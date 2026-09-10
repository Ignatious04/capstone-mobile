import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/widgets/text/button_text.dart';
import 'package:capstone/core/shared/widgets/text/section_title_text.dart';
import 'package:capstone/core/shared/widgets/text/supporting_info_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/core/utilities/call_launcher.dart';
import 'package:capstone/features/public_user/map/models/emergency_service_model.dart';
import 'package:capstone/features/public_user/map/providers/emergency_service_filter_provider.dart';
import 'package:capstone/features/public_user/map/providers/emergency_service_search_provider.dart';
import 'package:capstone/features/public_user/map/widgets/emergency_service_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EmergencyServicesPanel extends ConsumerStatefulWidget {
  const EmergencyServicesPanel({
    super.key,
    required this.currentLocation,
    required this.services,
    required this.mapController,
  });

  final LatLng currentLocation;
  final List<EmergencyServiceModel> services;
  final GoogleMapController mapController;

  @override
  ConsumerState<EmergencyServicesPanel> createState() => _EmergencyServicesPanelState();
}

class _EmergencyServicesPanelState extends ConsumerState<EmergencyServicesPanel> {
  final DraggableScrollableController _panelController = DraggableScrollableController();
  ScrollController? _scrollController;

  IconData _getServiceIcon(EmergencyServiceModel service) {
    switch (service.type) {
      case ServiceTypeEnum.fire:
        return Icons.local_fire_department;

      case ServiceTypeEnum.police:
        return Icons.local_police;

      case ServiceTypeEnum.medical:
        return Icons.local_hospital;
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

  double _getDistance(EmergencyServiceModel service) {
    return Geolocator.distanceBetween(
      widget.currentLocation.latitude,
      widget.currentLocation.longitude,
      service.location.latitude,
      service.location.longitude,
    );
  }

  String _formatDistance(EmergencyServiceModel service) {
    final distance = _getDistance(service);

    if (distance < 1000) {
      return '${distance.round()} m';
    }

    return '${(distance / 1000).toStringAsFixed(1)} km';
  }

  void _moveToService(LatLng location) {
    _panelController.animateTo(
      0.09,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    _scrollController?.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    widget.mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: 16,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _panelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortedServices = [...widget.services];

    sortedServices.sort((a, b) {
      return _getDistance(a).compareTo(_getDistance(b));
    });

    return DraggableScrollableSheet(
      controller: _panelController,
      initialChildSize: 0.30,
      minChildSize: 0.09,
      maxChildSize: 0.75,
      snap: true,
      snapSizes: const [
        0.09,
        0.30,
        0.75,
      ],
      builder:
          (
            BuildContext context,
            ScrollController scrollController,
          ) {
            _scrollController = scrollController;
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 10,
                              ),
                              child: Container(
                                width: 50,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: AppColors.lighterBlack,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                10,
                                20,
                                20,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: SectionTitleText(
                                          value: 'Nearby Emergency Services',
                                          isBold: true,
                                        ),
                                      ),
                                      SupportingInfoText(
                                        value: "${widget.services.length} location(s)",
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CustomTextField(
                                    title: "Search",
                                    onChanged: (value) {
                                      ref.read(emergencyServiceSearchProvider.notifier).setQuery(value);
                                    },
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Wrap(
                                    spacing: 8,
                                    children: ServiceTypeEnum.values.map((type) {
                                      final isSelected = ref.watch(emergencyServiceFilterProvider) == type;

                                      return ChoiceChip(
                                        label: ButtonText(
                                          value: type.name,
                                        ),
                                        selected: isSelected,
                                        onSelected: (_) {
                                          ref.read(emergencyServiceFilterProvider.notifier).setType(type);
                                        },
                                        selectedColor: Colors.deepOrange,
                                        labelStyle: TextStyle(
                                          color: isSelected ? Colors.white : Colors.black,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SliverList.builder(
                    itemCount: sortedServices.length,
                    itemBuilder: (context, index) {
                      final service = sortedServices[index];

                      return EmergencyServiceCard(
                        icon: _getServiceIcon(service),
                        iconColor: _getServiceColor(service),
                        title: service.name,
                        contactNumber: service.contactNumber,
                        address: service.address,
                        distance: _formatDistance(service),
                        status: service.isActive ? 'Open' : 'Unavailable',
                        onCallTap: () {
                          launchPhoneCall(service.contactNumber);
                        },
                        onTap: () {
                          _moveToService(LatLng(service.location.latitude, service.location.longitude));
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
    );
  }
}
