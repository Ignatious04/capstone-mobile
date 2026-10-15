import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/enums/location_status_enum.dart';
import 'package:capstone/core/shared/providers/location_provider.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/features/public_user/main/views/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocationGate extends ConsumerStatefulWidget {
  const LocationGate({super.key});

  @override
  ConsumerState<LocationGate> createState() => _LocationGateState();
}

class _LocationGateState extends ConsumerState<LocationGate> with WidgetsBindingObserver {
  bool _loading = true;
  String? _message;
  LocationStatusEnum? _status;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocation(silent: true);
    }
  }

  Future<void> _checkLocation({bool silent = false}) async {
    if (_checking) return;
    _checking = true;

    try {
      final locationService = ref.read(locationServiceProvider);

      final status = await locationService.checkLocationStatus();
      if (!mounted) return;

      if (status == LocationStatusEnum.ready) {
        _setReady();
        return;
      }

      final fixedServiceToggle =
          _status == LocationStatusEnum.serviceDisabled && status != LocationStatusEnum.serviceDisabled;

      if (silent && !fixedServiceToggle) {
        // Keep an already-visible error in sync, but never pop up a new one.
        if (_status != null && status != _status) _showError(status);
        return;
      }

      if (status == LocationStatusEnum.permissionDenied) {
        setState(() {
          _loading = true;
          _message = null;
        });

        final result = await locationService.requestPermission();
        if (!mounted) return;

        if (result == LocationStatusEnum.ready) {
          _setReady();
        } else {
          _showError(result);
        }
        return;
      }
      _showError(status);
    } catch (e) {
      // Without this, any platform exception leaves the spinner up forever.
      debugPrint('Location check failed: $e');
      if (mounted) _showError(LocationStatusEnum.permissionDenied);
    } finally {
      _checking = false;
    }
  }

  void _setReady() {
    setState(() {
      _loading = false;
      _message = null;
      _status = null;
    });
  }

  void _showError(LocationStatusEnum status) {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _loading = false;
      _status = status;
      _message = switch (status) {
        LocationStatusEnum.permissionDenied => l10n.locationPermissionRequired,
        LocationStatusEnum.permissionDeniedForever =>
          l10n.locationPermanentlyDenied,
        LocationStatusEnum.serviceDisabled => l10n.locationServicesOff,
        LocationStatusEnum.ready => null,
      };
    });
  }

  Future<void> _handleRetry() async {
    final locationService = ref.read(locationServiceProvider);

    switch (_status) {
      case LocationStatusEnum.permissionDeniedForever:
        await locationService.openAppSettings();
        break;
      case LocationStatusEnum.serviceDisabled:
        await locationService.openLocationSettings();
        break;
      default:
        await _checkLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CustomCircularProgressIndicator(),
        ),
      );
    }

    if (_message != null) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 100,
                        color: Colors.black54,
                      ),
                      const SizedBox(height: 10),
                      BodyText(
                        value: _message!,
                        alignment: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: CustomElevatedButton(
                  onPressed: _handleRetry,
                  value: l10n.openSettings,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const MainScreen();
  }
}
