import 'package:capstone/core/enums/location_status_enum.dart';
import 'package:capstone/core/shared/providers/location_provider.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
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
    final locationService = ref.read(locationServiceProvider);

    final status = await locationService.checkLocationStatus();
    if (!mounted) return;

    if (status == LocationStatusEnum.ready) {
      setState(() {
        _loading = false;
        _message = null;
        _status = null;
      });
      return;
    }

    // A silent (app-resumed) recheck should only ever *clear* an error,
    // never pop up a new one or reopen Settings on its own.
    if (silent) return;

    setState(() {
      _loading = true;
      _message = null;
    });

    switch (status) {
      case LocationStatusEnum.ready:
        return; // handled above

      case LocationStatusEnum.permissionDenied:
        final result = await locationService.requestPermission();
        if (!mounted) return;

        if (result == LocationStatusEnum.ready) {
          setState(() {
            _loading = false;
            _message = null;
            _status = null;
          });
          return;
        }

        setState(() {
          _loading = false;
          _message = "Location permission is required to continue.";
          _status = LocationStatusEnum.permissionDenied;
        });
        return;

      case LocationStatusEnum.permissionDeniedForever:
        setState(() {
          _loading = false;
          _message = "Location permission has been permanently denied. Please enable it in Settings.";
          _status = LocationStatusEnum.permissionDeniedForever;
        });
        return;

      case LocationStatusEnum.serviceDisabled:
        setState(() {
          _loading = false;
          _message = "Please enable Location Services to continue.";
          _status = LocationStatusEnum.serviceDisabled;
        });
        return;
    }
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
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CustomCircularProgressIndicator(),
        ),
      );
    }

    if (_message != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _message!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _handleRetry,
                  child: const Text("Try Again"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const MainScreen();
  }
}
