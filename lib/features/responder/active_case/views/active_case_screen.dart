// lib/features/responder/active_case/views/active_case_screen.dart
import 'package:capstone/core/enums/map_mode_enum.dart';
import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/text/data_label_text.dart';
import 'package:capstone/core/shared/widgets/text/data_value_text.dart';
import 'package:capstone/core/shared/widgets/text/paragraph_text.dart';
import 'package:capstone/core/shared/widgets/text/screen_title_text.dart';
import 'package:capstone/core/shared/widgets/text/supporting_info_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/core/utilities/formatter.dart';
import 'package:capstone/features/public_user/map/widgets/map_tile_widget.dart';
import 'package:capstone/features/public_user/reporting/models/report_model.dart';
import 'package:capstone/features/public_user/reporting/providers/report_repository_provider.dart';
import 'package:capstone/features/public_user/reporting/widgets/additional_information_card.dart';
import 'package:capstone/features/public_user/reporting/widgets/attachments_card.dart';
import 'package:capstone/features/public_user/reporting/widgets/report_status_widget.dart';
import 'package:capstone/features/public_user/reporting/widgets/section_title.dart';
import 'package:capstone/features/public_user/reporting/widgets/victims_card.dart';
import 'package:capstone/features/responder/active_case/widgets/active_case_action_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/active_case_provider.dart';

class ActiveCaseScreen extends ConsumerWidget {
  const ActiveCaseScreen({super.key});

  Future<void> _advanceStatus(WidgetRef ref, ReportModel report) async {
    final repo = ref.read(reportRepositoryProvider);
    final next = switch (report.status) {
      ReportStatusEnum.pending => ReportStatusEnum.accepted, // Accept
      ReportStatusEnum.accepted => ReportStatusEnum.dispatched, // En Route
      ReportStatusEnum.dispatched => ReportStatusEnum.onScene, // Arrived
      ReportStatusEnum.onScene => ReportStatusEnum.resolved, // Resolve
      _ => null,
    };
    if (next == null) return;
    await repo.updateReportStatus(report.reportID, next);
  }

  Future<void> _decline(WidgetRef ref, ReportModel report) async {
    await ref.read(reportRepositoryProvider).declineAssignment(report.reportID);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caseAsync = ref.watch(activeCaseProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: caseAsync.when(
          data: (report) {
            if (report == null) {
              return const _NoActiveCase();
            }
            return _ActiveCaseBody(
              report: report,
              onAccept: () => _advanceStatus(ref, report),
              onDecline: () => _decline(ref, report),
              onAdvance: () => _advanceStatus(ref, report),
            );
          },
          loading: () => const Center(child: CustomCircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
        ),
      ),
    );
  }
}

class _NoActiveCase extends StatelessWidget {
  const _NoActiveCase();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_hospital, size: 64, color: AppColors.darkerGrey),
            SizedBox(height: 16),
            ScreenTitleText(value: "No active case"),
            SizedBox(height: 8),
            SupportingInfoText(
              value: "You'll be notified here when a case is assigned to you.",
              color: AppColors.darkerGrey,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveCaseBody extends StatelessWidget {
  const _ActiveCaseBody({
    required this.report,
    required this.onAccept,
    required this.onDecline,
    required this.onAdvance,
  });

  final ReportModel report;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final location = report.location;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // Map — ~45% of the screen
        SizedBox(
          height: screenHeight * 0.45,
          width: double.infinity,
          child: location == null
              ? Container(
                  color: Colors.grey.shade300,
                  child: const Center(child: Text('No location on this report')),
                )
              : Stack(
                  children: [
                    Positioned.fill(
                      child: MapTileWidget(
                        initialLocation: LatLng(location.latitude, location.longitude),
                        mode: MapModeEnum.view,
                        extraMarkers: {
                          Marker(
                            markerId: const MarkerId('incident'),
                            position: LatLng(location.latitude, location.longitude),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed,
                            ),
                          ),
                        },
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: FloatingActionButton.small(
                        heroTag: 'directionsFAB',
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepOrange,
                        onPressed: () async {
                          final uri = Uri.parse(
                            'https://www.google.com/maps/dir/?api=1'
                            '&destination=${location.latitude},${location.longitude}'
                            '&travelmode=driving',
                          );
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        },
                        child: const Icon(Icons.directions),
                      ),
                    ),
                  ],
                ),
        ),

        // Details — scrollable, fills the rest
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
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
                              child: const Icon(Icons.emergency_outlined, size: 30, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const DataLabelText(value: 'EMERGENCY TYPE'),
                                  DataValueText(
                                    value: Formatter.formatEnumName(report.incidentType?.name ?? '—'),
                                    isBold: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ReportStatusWidget(status: report.status!.name),
                        const SizedBox(height: 10),
                        const DataLabelText(value: 'REFERENCE NUMBER'),
                        DataValueText(value: report.referenceNumber),
                        const SizedBox(height: 10),
                        const DataLabelText(value: 'DESCRIPTION'),
                        ParagraphText(
                          value: report.description.isEmpty ? 'No description provided.' : report.description,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SectionTitle(icon: Icons.people_outline, title: 'Victims'),
                const SizedBox(height: 10),
                VictimsCard(victims: report.victims),
                const SizedBox(height: 10),
                SectionTitle(icon: Icons.attach_file, title: 'Attachments'),
                const SizedBox(height: 10),
                AttachmentsCard(attachments: report.attachments),
                const SizedBox(height: 10),
                SectionTitle(icon: Icons.notes, title: 'Additional Information'),
                const SizedBox(height: 10),
                AdditionalInformationCard(additionalInfo: report.additionalInformation.trim()),
                const SizedBox(height: 20),
                ActiveCaseActionBar(
                  status: report.status!,
                  onAccept: onAccept,
                  onDecline: onDecline,
                  onAdvance: onAdvance,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}