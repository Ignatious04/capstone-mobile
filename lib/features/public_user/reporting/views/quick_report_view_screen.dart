import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/shared/providers/report_repository_provider.dart';
import 'package:capstone/core/shared/providers/responder_provider.dart';
import 'package:capstone/core/shared/widgets/emergency_guidance_sheet.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/core/utilities/formatter.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/info_column.dart';
import 'package:capstone/core/shared/models/report_model.dart';
import 'package:capstone/features/public_user/reporting/providers/responder_location_provider.dart';
import 'package:capstone/features/public_user/reporting/widgets/eta_card.dart';
import 'package:capstone/features/public_user/reporting/widgets/location_card.dart';
import 'package:capstone/features/public_user/reporting/widgets/report_status_widget.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:capstone/features/public_user/reporting/widgets/responder_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class QuickReportViewScreen extends ConsumerWidget {
  const QuickReportViewScreen({
    super.key,
    required this.report,
  });

  final ReportModel report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentReport = ref
        .watch(reportByIdProvider(report.reportID))
        .maybeWhen(data: (r) => r ?? report, orElse: () => report);

    final status = currentReport.status!.name;
    final location = currentReport.location;
    final assignedResponderID = currentReport.assignedTo ?? "";
    final responderAsync = assignedResponderID.isEmpty ? null : ref.watch(responderByIdProvider(assignedResponderID));
    final showResponderLocation = assignedResponderID.isNotEmpty && currentReport.status != ReportStatusEnum.resolved;
    final responderLatLng = showResponderLocation
        ? ref.watch(responderLocationProvider(currentReport.reportID)).value
        : null;
    final incidentLatLng = LatLng(location!.latitude, location.longitude);
    // final information = report.additionalInformation.trim();
    return Scaffold(
      appBar: CustomAppBar(
        value: "View Report",
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: "While you wait",
            onPressed: () => EmergencyGuidanceSheet.show(context, currentReport.incidentType!),
          ),
        ],
      ),
      body: SafeArea(
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
                                  value: 'EMERGENCY TYPE',
                                ),
                                BodyText(
                                  value: Formatter.formatEnumName(currentReport.incidentType!.name),
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
                      Divider(
                        height: 1,
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.quickreply,
                          color: Colors.green,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.center,
                        child: const TitleText(
                          value: "Quick Report",
                        ),
                      ),
                      const SizedBox(height: 10),
                      const BodyText(
                        value: "This report was submitted through the quick-reporting module.",
                        alignment: TextAlign.center,
                        isOverflow: false,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
                  isOnScene: currentReport.status == ReportStatusEnum.onScene,
                ),
                const SizedBox(height: 10),
              ],
              LocationCard(
                location: location,
                responderLocation: responderLatLng,
              ),
              const SizedBox(height: 10),
              SectionTitle(
                icon: Icons.info,
                title: 'Incident Information',
              ),
              const SizedBox(height: 10),
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoColumn(
                        title: "REFERENCE NUMBER",
                        value: currentReport.referenceNumber,
                      ),
                      const SizedBox(height: 10),
                      InfoColumn(
                        title: "SUBMITTED",
                        value: currentReport.createdAt != null
                            ? DateFormat(
                                "MMMM dd, yyyy • hh:mm a",
                              ).format(currentReport.createdAt!)
                            : "-",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
