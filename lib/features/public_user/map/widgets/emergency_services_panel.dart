import 'package:capstone/core/enums/audit_action_enum.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/shared/providers/audit_log_repository_provider.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/core/utilities/call_launcher.dart';
import 'package:capstone/core/utilities/directions_launcher.dart';
import 'package:capstone/core/utilities/distance_helper.dart';
import 'package:capstone/core/utilities/formatter.dart';
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

  double _getDistance(EmergencyServiceModel service) {
    return Geolocator.distanceBetween(
      widget.currentLocation.latitude,
      widget.currentLocation.longitude,
      service.location.latitude,
      service.location.longitude,
    );
  }

  void _moveToService(LatLng location) {
    _panelController.animateTo(
      0.15,
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
    final withDistance = [
      for (final s in widget.services) (service: s, meters: _getDistance(s)),
    ]..sort((a, b) => a.meters.compareTo(b.meters));

    return DraggableScrollableSheet(
      controller: _panelController,
      initialChildSize: 0.15,
      minChildSize: 0.15,
      maxChildSize: 0.75,
      snap: true,
      snapSizes: const [
        0.15,
        0.35,
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
                                top: 20,
                              ),
                              child: Container(
                                width: 50,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.black54,
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
                                        child: TitleText(
                                          value: 'Nearby Emergency Services',
                                          isBold: true,
                                        ),
                                      ),
                                      BodyText(
                                        value: "${widget.services.length} location(s)",
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CustomTextField(
                                    title: "SEARCH",
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
                                        label: BodyText(
                                          value: Formatter.formatEnumName(type.name),
                                          isBold: true,
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
                    itemCount: withDistance.length,
                    itemBuilder: (context, index) {
                      final item = withDistance[index];
                      final service = item.service;

                      return EmergencyServiceCard(
                        icon: _getServiceIcon(service),
                        iconColor: _getServiceColor(service),
                        backgroundColor: _getServiceBackgroundColor(service),
                        title: service.name,
                        contactNumber: service.contactNumber,
                        address: service.address,
                        distance: DistanceHelper.formatDistance(item.meters),
                        status: service.isActive ? 'Open' : 'Unavailable',
                        onCallTap: () {
                          ref
                              .read(auditLogRepositoryProvider)
                              .log(
                                AuditAction.emergencyCallInitiated,
                                targetType: 'emergencyService',
                                metadata: {
                                  'source': 'map',
                                  'serviceName': service.name,
                                  'number': service.contactNumber,
                                },
                              );
                          launchPhoneCall(service.contactNumber);
                        },
                        onDirectionsTap: () {
                          ref
                              .read(auditLogRepositoryProvider)
                              .log(
                                AuditAction.directionsRequested,
                                targetType: 'emergencyService',
                                metadata: {
                                  'source': 'map',
                                  'serviceName': service.name,
                                },
                              );
                          launchDirections(
                            service.location.latitude,
                            service.location.longitude,
                          );
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
