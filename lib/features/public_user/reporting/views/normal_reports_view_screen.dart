import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/shared/providers/report_repository_provider.dart';
import 'package:capstone/core/shared/providers/responder_provider.dart';
import 'package:capstone/core/shared/widgets/emergency_guidance_sheet.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/utilities/formatter.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/models/report_model.dart';
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
    // Live copy of the report; falls back to the one passed in while loading/on error.
    final report = ref
        .watch(reportByIdProvider(widget.report.reportID))
        .maybeWhen(data: (r) => r ?? widget.report, orElse: () => widget.report);

    final status = report.status!.name;
    final location = report.location!;
    final information = report.additionalInformation.trim();
    final showGuidanceEntry = !(report.incidentType == ServiceTypeEnum.police && report.policeConcernType != null);
    final assignedResponderID = report.assignedTo ?? "";
    final responderAsync = assignedResponderID.isEmpty ? null : ref.watch(responderByIdProvider(assignedResponderID));
    final showResponderLocation = assignedResponderID.isNotEmpty && report.status != ReportStatusEnum.resolved;
    final responderLatLng = showResponderLocation ? ref.watch(responderLocationProvider(report.reportID)).value : null;
    final incidentLatLng = LatLng(location.latitude, location.longitude);

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
                  onPressed: () => EmergencyGuidanceSheet.show(context, report.incidentType!),
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
                                    value: Formatter.formatEnumName(report.incidentType!.name),
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
                          value: report.description.isEmpty ? 'No description provided.' : report.description,
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
                ],
                const SizedBox(height: 10),
                SectionTitle(
                  icon: Icons.location_on_outlined,
                  title: responderLatLng == null ? 'Incident Location' : 'Incident & Responder Location',
                ),
                const SizedBox(height: 10),
                if (responderLatLng != null) ...[
                  EtaCard(
                    responder: responderLatLng,
                    incident: incidentLatLng,
                    isOnScene: report.status == ReportStatusEnum.onScene,
                  ),
                  const SizedBox(height: 10),
                ],
                LocationCard(location: location, responderLocation: responderLatLng),
                const SizedBox(height: 10),
                SectionTitle(
                  icon: Icons.people_outline,
                  title: 'Victims',
                ),
                const SizedBox(height: 10),
                VictimsCard(
                  victims: report.victims,
                ),
                const SizedBox(height: 10),
                SectionTitle(
                  icon: Icons.attach_file,
                  title: 'Attachments',
                ),
                const SizedBox(height: 10),
                AttachmentsCard(
                  attachments: report.attachments,
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
