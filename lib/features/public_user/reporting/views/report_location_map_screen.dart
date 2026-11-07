import 'package:capstone/core/enums/map_mode_enum.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/utilities/case_marker_icons.dart';
import 'package:capstone/features/public_user/map/widgets/map_tile_widget.dart';
import 'package:capstone/features/public_user/reporting/providers/responder_location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Full-screen, interactive version of the map in LocationCard: the same
/// incident pin and live responder pins, but you can pan and zoom.
class ReportLocationMapScreen extends ConsumerStatefulWidget {
  const ReportLocationMapScreen({
    super.key,
    required this.incident,
    this.responders = const [],
  });

  final LatLng incident;
  final List<ResponderKey> responders;

  @override
  ConsumerState<ReportLocationMapScreen> createState() => _ReportLocationMapScreenState();
}

class _ReportLocationMapScreenState extends ConsumerState<ReportLocationMapScreen> {
  // MapTileWidget re-fits the camera whenever fitToPoints changes. Fit once on open,
  // otherwise every responder location update would yank the camera back mid-pan.
  List<LatLng>? _initialFit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final positions = watchResponderPositions(ref, widget.responders);
    final icons = ref.watch(caseMarkerIconsProvider).value;

    _initialFit ??= positions.isEmpty ? const [] : [widget.incident, ...positions];

    return Scaffold(
      appBar: CustomAppBar(
        value: positions.isEmpty ? l10n.incidentLocation : l10n.incidentAndResponderLocation,
      ),
      body: MapTileWidget(
        initialLocation: widget.incident,
        fitToPoints: _initialFit!,
        mode: MapModeEnum.view,
        gesturesEnabled: true,
        extraMarkers: buildCaseMarkers(
          icons: icons,
          incident: widget.incident,
          responders: positions,
        ),
      ),
    );
  }
}