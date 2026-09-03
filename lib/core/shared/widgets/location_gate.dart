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
      _checkLocation();
    }
  }

  Future<void> _checkLocation() async {
    final locationService = ref.read(locationServiceProvider);

    setState(() {
      _loading = true;
      _message = null;
    });

    while (mounted) {
      final status = await locationService.checkLocationStatus();

      switch (status) {
        case LocationStatusEnum.ready:
          if (!mounted) return;

          setState(() {
            _loading = false;
            _message = null;
          });

          return;

        case LocationStatusEnum.permissionDenied:
          final result = await locationService.requestPermission();

          if (result == LocationStatusEnum.ready) {
            continue;
          }

          setState(() {
            _loading = false;
            _message = "Location permission is required to continue.";
          });

          return;

        case LocationStatusEnum.permissionDeniedForever:
          await locationService.openAppSettings();

          setState(() {
            _message = "Location permission has been permanently denied. Please enable it in Settings.";
            _loading = false;
          });

          return;

        case LocationStatusEnum.serviceDisabled:
          await locationService.openLocationSettings();

          setState(() {
            _message = "Please enable Location Services to continue.";
            _loading = false;
          });

          return;
      }
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
                  onPressed: _checkLocation,
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
