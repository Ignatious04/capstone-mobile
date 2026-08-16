import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/shared/widgets/text/section_title_text.dart';
import 'package:capstone/core/shared/widgets/text/supporting_info_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/map/models/emergency_service_model.dart';
import 'package:capstone/features/map/widgets/emergency_service_card.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EmergencyServicesPanel extends StatelessWidget {
  const EmergencyServicesPanel({
    super.key,
    required this.currentLocation,
    required this.services,
  });

  final LatLng currentLocation;
  final List<EmergencyServiceModel> services;

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

  double _getDistance(EmergencyServiceModel service) {
    return Geolocator.distanceBetween(
      currentLocation.latitude,
      currentLocation.longitude,
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

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.15,
      minChildSize: 0.15,
      maxChildSize: 0.75,
      snap: true,
      snapSizes: const [
        0.15,
        0.75,
      ],
      builder:
          (
            BuildContext context,
            ScrollController scrollController,
          ) {
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
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                            bottom: 10,
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
                            10,
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                child: SectionTitleText(
                                  value: 'Nearby Emergency Services',
                                  isBold: true,
                                ),
                              ),
                              SupportingInfoText(
                                value: "${services.length} location(s)",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverList.builder(
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];

                      return EmergencyServiceCard(
                        icon: _getServiceIcon(service),
                        title: service.name,
                        subtitle: service.address,
                        distance: _formatDistance(service),
                        status: service.isActive ? 'Open' : 'Unavailable',
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
