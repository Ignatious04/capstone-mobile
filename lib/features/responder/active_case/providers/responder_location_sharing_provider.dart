import 'package:capstone/core/shared/providers/locale_provider.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'dart:async';

import 'package:capstone/core/enums/location_status_enum.dart';
import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/services/location_service.dart';
import 'package:capstone/core/shared/models/realtime_responder_location_model.dart';
import 'package:capstone/core/shared/providers/location_provider.dart';
import 'package:capstone/core/shared/providers/realtime_database_repository_provider.dart';
import 'package:capstone/core/shared/repositories/realtime_database_repository.dart';
import 'package:capstone/features/responder/active_case/providers/active_case_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final responderLocationSharingProvider = Provider<ResponderLocationSharer>((ref) {
  final sharer = ResponderLocationSharer(
    database: ref.read(realtimeDatabaseRepositoryProvider),
    locationService: ref.read(locationServiceProvider),
    l10n: () => lookupAppLocalizations(ref.read(localeProvider)),
  );
  ref.onDispose(sharer.dispose);

  ref.listen<AsyncValue<ActiveCase?>>(
    activeCaseProvider,
    (_, next) {
      final data = next.asData;
      if (data == null) return; // still loading: don't stop sharing on a blip
      sharer.sync(data.value);
    },
    fireImmediately: true,
  );
  return sharer;
});

class ResponderLocationSharer {
  ResponderLocationSharer({required this.database, required this.locationService, required this.l10n});

  Future<void> stopSharing() => _stop();

  final RealtimeDatabaseRepository database;
  final LocationService locationService;

  /// Looked up when sharing starts, so the foreground notification uses the current language.
  final AppLocalizations Function() l10n;

  StreamSubscription<LatLng>? _subscription;
  String? _sharingReportID;
  String? _sharingResponderID;

  static bool _shouldShare(ActiveCase? activeCase) {
    final response = activeCase?.response;
    if (response == null || response.assignedTo == null) return false;
    return response.status == ReportStatusEnum.dispatched || response.status == ReportStatusEnum.onScene;
  }

  /// One node per responder, so several services on one report don't overwrite each other.
  String _path(String reportID, String responderID) => 'responderLocations/$reportID/$responderID';

  Future<void> sync(ActiveCase? activeCase) async {
    if (activeCase == null || !_shouldShare(activeCase)) {
      await _stop();
      return;
    }
    if (_sharingReportID == activeCase.response.reportID) return; // already sharing this case
    await _stop();
    await _start(activeCase);
  }

  Future<void> _start(ActiveCase activeCase) async {
    final reportID = activeCase.response.reportID;
    _sharingReportID = reportID;
    _sharingResponderID = activeCase.response.assignedTo;

    // Responders skip LocationGate, so nothing else asks them for permission.
    final permission = await locationService.requestPermission();
    if (_sharingReportID != reportID) return; // case ended while we waited
    if (permission != LocationStatusEnum.ready) {
      _sharingReportID = null;
      return;
    }

    // The stream only fires after movement, so publish an initial fix first.
    try {
      final fix = await locationService.getCurrentLocation();
      await _publish(activeCase, fix.latLng);
    } catch (e) {
      debugPrint('Initial responder location failed: $e');
    }
    if (_sharingReportID != reportID) return;

    _subscription = locationService.getResponderLocationStream(l10n: l10n()).listen(
      (latLng) => _publish(activeCase, latLng),
      onError: (e) => debugPrint('Responder location stream error: $e'),
    );
  }

  Future<void> _publish(ActiveCase activeCase, LatLng latLng) async {
    final response = activeCase.response;
    if (_sharingReportID != response.reportID) return;

    final model = RealtimeResponderLocationModel(
      reportID: response.reportID,
      responderID: response.assignedTo ?? '',
      userID: response.userID,
      latitude: latLng.latitude,
      longitude: latLng.longitude,
      updatedAt: DateTime.now(),
    );

    try {
      await database.create(path: _path(response.reportID, response.assignedTo ?? ''), data: model.toMap());
    } catch (e) {
      debugPrint('Publishing responder location failed: $e');
    }
  }

  Future<void> _stop() async {
    await _subscription?.cancel();
    _subscription = null;

    final reportID = _sharingReportID;
    final responderID = _sharingResponderID;
    _sharingReportID = null;
    _sharingResponderID = null;
    if (reportID == null || responderID == null) return;

    try {
      await database.delete(path: _path(reportID, responderID));
    } catch (e) {
      debugPrint('Removing responder location failed: $e');
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _sharingReportID = null;
    _sharingResponderID = null;
  }
}
