import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/l10n/enum_labels.dart';
import 'package:capstone/core/shared/models/report_model.dart';
import 'package:capstone/core/shared/models/response_model.dart';
import 'package:capstone/core/shared/providers/responder_provider.dart';
import 'package:capstone/core/shared/providers/response_repository_provider.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/public_user/reporting/providers/responder_location_provider.dart';
import 'package:capstone/features/public_user/reporting/widgets/eta_card.dart';
import 'package:capstone/features/public_user/reporting/widgets/location_card.dart';
import 'package:capstone/features/public_user/reporting/widgets/reporting_timeline_card.dart';
import 'package:capstone/features/public_user/reporting/widgets/responder_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Everything about who is responding to a report: one block per service
/// (responder + that service's own timeline), then a single map with the
/// incident and every responder who is sharing their location.
///
/// Replaces the single responder card / timeline / ETA / map that the four
/// report view screens each built from `report.assignedTo`.
class ReportResponsesSection extends ConsumerWidget {
  const ReportResponsesSection({super.key, required this.report});

  final ReportModel report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final responsesAsync = ref.watch(
      responsesForReportProvider((reportID: report.reportID, userID: report.userID)),
    );
    final responses = responsesAsync.value ?? const <ResponseModel>[];
    final loadingResponses = responsesAsync.isLoading && !responsesAsync.hasValue;

    // Live pins: only responders who are assigned, unresolved and sharing.
    final live = <({ResponseModel response, LatLng position})>[];
    for (final response in responses) {
      final responderID = response.assignedTo;
      if (responderID == null || response.status == ReportStatusEnum.resolved) continue;
      final position = ref
          .watch(responderLocationProvider((reportID: response.reportID, responderID: responderID)))
          .value;
      if (position != null) live.add((response: response, position: position));
    }

    final location = report.location;
    final incident = location == null ? null : LatLng(location.latitude, location.longitude);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // const SizedBox(height: 10),
        SectionTitle(icon: Icons.timeline, title: l10n.statusTimeline),
        const SizedBox(height: 10),
        if (loadingResponses)
          const _ResponderPlaceholder()
        else if (responses.isEmpty) ...[
          ReportTimelineCard(createdAt: report.createdAt),
        ],
        for (final response in responses) ...[
          _ResponseCard(createdAt: report.createdAt, response: response),
          const SizedBox(height: 10),
        ],
        if (location != null && incident != null) ...[
          const SizedBox(height: 10),
          SectionTitle(
            icon: Icons.location_on_outlined,
            title: live.isEmpty ? l10n.incidentLocation : l10n.incidentAndResponderLocation,
          ),
          const SizedBox(height: 10),
          for (final item in live) ...[
            EtaCard(
              responder: item.position,
              incident: incident,
              isOnScene: item.response.status == ReportStatusEnum.onScene,
              title: live.length > 1 ? '${item.response.serviceType.label(l10n)} - ${l10n.estimatedArrival}' : null,
            ),
            const SizedBox(height: 10),
          ],
          LocationCard(
            location: location,
            responderLocations: [for (final item in live) item.position],
          ),
        ],
      ],
    );
  }
}

/// One card per service: the responder on top, a divider, then that service's
/// timeline tucked inside a collapsible tile.
///
/// A red dot sits on the timeline icon whenever this service's status has
/// changed since the user last opened its timeline. The last status the user
/// saw is remembered per response in SharedPreferences.
class _ResponseCard extends StatefulWidget {
  const _ResponseCard({required this.createdAt, required this.response});

  final DateTime? createdAt;
  final ResponseModel response;

  @override
  State<_ResponseCard> createState() => _ResponseCardState();
}

class _ResponseCardState extends State<_ResponseCard> {
  String? _seenStatus; // null until loaded from storage
  bool _expanded = false;

  String get _key => 'seen_status_${widget.response.responseID}';
  bool get _hasUpdate => _seenStatus != null && _seenStatus != widget.response.status.name;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _ResponseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Status changed while the timeline is open: they're looking at it, so no dot.
    if (_expanded && oldWidget.response.status != widget.response.status) _markSeen();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    // Never seen before -> compare against `pending`, so any progress shows a dot.
    setState(() => _seenStatus = prefs.getString(_key) ?? ReportStatusEnum.pending.name);
  }

  Future<void> _markSeen() async {
    final status = widget.response.status.name;
    if (_seenStatus == status) return;
    setState(() => _seenStatus = status);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, status);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final response = widget.response;
    final responderID = response.assignedTo;

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias, // keeps the tile's ripple inside the rounded corners
      child: Column(
        children: [
          if (responderID != null)
            _AssignedResponder(responderID: responderID)
          else
            _UnassignedHeader(response: response),
          const Divider(height: 1),
          // ExpansionTile draws its own top/bottom borders; hide them.
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 20),
              childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
              onExpansionChanged: (open) {
                _expanded = open;
                if (open) _markSeen();
              },
              leading: Badge(
                isLabelVisible: _hasUpdate,
                smallSize: 10,
                backgroundColor: Colors.red,
                child: const Icon(Icons.timeline, color: Colors.deepOrange),
              ),
              title: BodyText(value: l10n.statusTimeline),
              children: [
                ReportTimelineCard(createdAt: widget.createdAt, response: response, embedded: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Stands in for the ResponderCard until a responder is assigned, so each
/// service's card is still identifiable (icon + service name + status).
class _UnassignedHeader extends StatelessWidget {
  const _UnassignedHeader({required this.response});

  final ResponseModel response;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final (icon, color, background) = switch (response.serviceType) {
      ServiceTypeEnum.medical => (Icons.local_hospital, Colors.green, AppColors.lighterGreen),
      ServiceTypeEnum.police => (Icons.local_police, Colors.blue, AppColors.lighterBlue),
      ServiceTypeEnum.fire => (Icons.local_fire_department, Colors.red, AppColors.lighterRed),
    };

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 30, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LabelText(value: l10n.responder.toUpperCase()),
                BodyText(value: response.serviceType.label(l10n), isBold: true),
                BodyText(value: l10n.awaitingResponder, color: Colors.black54),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignedResponder extends ConsumerWidget {
  const _AssignedResponder({required this.responderID});

  final String responderID;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responderAsync = ref.watch(responderByIdProvider(responderID));
    final responder = responderAsync.value;
    if (responder == null) {
      // Bare spinner: the parent _ResponseCard already provides the Card.
      return responderAsync.isLoading
          ? const SizedBox(height: 120, child: Center(child: CustomCircularProgressIndicator()))
          : const SizedBox.shrink();
    }
    return ResponderCard(responder: responder, embedded: true);
  }
}

class _ResponderPlaceholder extends StatelessWidget {
  const _ResponderPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      child: SizedBox(
        height: 120, // roughly the real ResponderCard height
        child: Center(
          child: CustomCircularProgressIndicator(),
        ),
      ),
    );
  }
}
