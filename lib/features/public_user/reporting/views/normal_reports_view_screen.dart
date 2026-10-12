import 'package:capstone/core/enums/map_mode_enum.dart';
import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/shared/providers/responder_provider.dart';
import 'package:capstone/core/shared/widgets/emergency_guidance_sheet.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/utilities/formatter.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/models/report_model.dart';
import 'package:capstone/features/public_user/map/widgets/map_tile_widget.dart';
import 'package:capstone/features/public_user/reporting/providers/responder_location_provider.dart';
import 'package:capstone/features/public_user/reporting/widgets/additional_information_card.dart';
import 'package:capstone/features/public_user/reporting/widgets/attachments_card.dart';
import 'package:capstone/features/public_user/reporting/widgets/eta_card.dart';
import 'package:capstone/features/public_user/reporting/widgets/location_card.dart';
import 'package:capstone/features/public_user/reporting/widgets/report_status_widget.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:capstone/features/public_user/reporting/widgets/responder_card.dart';
import 'package:capstone/features/public_user/reporting/widgets/victims_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NormalReportsViewScreen extends ConsumerStatefulWidget {
  const NormalReportsViewScreen({
    super.key,
    required this.report,
  });

  final ReportModel report;

  @override
  ConsumerState<NormalReportsViewScreen> createState() => _NormalReportsViewScreenState();
}

class _NormalReportsViewScreenState extends ConsumerState<NormalReportsViewScreen> {
  @override
  Widget build(BuildContext context) {
    final status = widget.report.status!.name;
    final location = widget.report.location;
    final information = widget.report.additionalInformation.trim();
    final showGuidanceEntry =
        !(widget.report.incidentType == ServiceTypeEnum.police && widget.report.policeConcernType != null);
    final assignedResponderID = widget.report.assignedTo ?? "";
    final responderAsync = assignedResponderID.isEmpty ? null : ref.watch(responderByIdProvider(assignedResponderID));

    return Scaffold(
      appBar: CustomAppBar(
        value: "View Report",
        actions: showGuidanceEntry
            ? [
                IconButton(
                  icon: const Icon(
                    Icons.info_outline,
                    size: 25,
                  ),
                  tooltip: "While you wait",
                  onPressed: () => EmergencyGuidanceSheet.show(context, widget.report.incidentType!),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: Colors.white,
                  elevation: 1,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.emergency_outlined,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const BodyText(
                                    value: 'INCIDENT TYPE',
                                  ),
                                  BodyText(
                                    value: Formatter.formatEnumName(widget.report.incidentType!.name),
                                    isBold: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ReportStatusWidget(
                          status: status,
                        ),
                        const SizedBox(height: 10),
                        const LabelText(
                          value: 'DESCRIPTION',
                        ),
                        BodyText(
                          value: widget.report.description.isEmpty
                              ? 'No description provided.'
                              : widget.report.description,
                        ),
                      ],
                    ),
                  ),
                ),
                if (responderAsync != null) ...[
                  const SizedBox(height: 10),
                  responderAsync.when(
                    data: (responder) => responder == null
                        ? const SizedBox.shrink()
                        : Column(
                            children: [
                              SectionTitle(icon: Icons.support_agent, title: 'Responder'),
                              const SizedBox(height: 10),
                              ResponderCard(responder: responder),
                            ],
                          ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  if (assignedResponderID.isNotEmpty && widget.report.status != ReportStatusEnum.resolved)
                    ...ref
                        .watch(responderLocationProvider(widget.report.reportID))
                        .maybeWhen(
                          data: (responderLatLng) {
                            if (responderLatLng == null) return <Widget>[];
                            final incident = LatLng(location!.latitude, location.longitude);
                            return [
                              const SizedBox(height: 10),
                              SectionTitle(icon: Icons.my_location, title: 'Responder Location'),
                              const SizedBox(height: 10),
                              EtaCard(
                                responder: responderLatLng,
                                incident: incident,
                                isOnScene: widget.report.status == ReportStatusEnum.onScene,
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 250,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: MapTileWidget(
                                    initialLocation: incident,
                                    fitToPoints: [incident, responderLatLng],
                                    mode: MapModeEnum.view,
                                    gesturesEnabled: true,
                                    extraMarkers: {
                                      Marker(
                                        markerId: const MarkerId('incident'),
                                        position: incident,
                                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                                      ),
                                      Marker(
                                        markerId: const MarkerId('responder'),
                                        position: responderLatLng,
                                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                                      ),
                                    },
                                  ),
                                ),
                              ),
                            ];
                          },
                          orElse: () => <Widget>[],
                        ),
                ],
                const SizedBox(height: 10),
                SectionTitle(
                  icon: Icons.location_on_outlined,
                  title: 'Incident Location',
                ),
                const SizedBox(height: 10),
                LocationCard(location: location!),
                const SizedBox(height: 10),
                SectionTitle(
                  icon: Icons.people_outline,
                  title: 'Victims',
                ),
                const SizedBox(height: 10),
                VictimsCard(
                  victims: widget.report.victims,
                ),
                const SizedBox(height: 10),
                SectionTitle(
                  icon: Icons.attach_file,
                  title: 'Attachments',
                ),
                const SizedBox(height: 10),
                AttachmentsCard(
                  attachments: widget.report.attachments,
                ),
                const SizedBox(height: 10),
                SectionTitle(
                  icon: Icons.notes,
                  title: 'Additional Information',
                ),
                const SizedBox(height: 10),
                AdditionalInformationCard(
                  additionalInfo: information,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
