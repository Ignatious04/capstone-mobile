import 'package:capstone/core/enums/map_mode_enum.dart';
import 'package:capstone/core/shared/widgets/text/deprecated/text_title_small.dart';
import 'package:capstone/features/map/widgets/map_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({
    super.key,
    required this.initialLocation,
  });

  final LatLng initialLocation;

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  late LatLng _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        title: const TextTitleSmall(
          title: "Back",
          color: Colors.white,
        ),
        titleSpacing: 0,
      ),
      body: MapTileWidget(
        initialLocation: _selectedLocation,
        mode: MapModeEnum.selectLocation,
        onLocationChanged: (location) {
          setState(() {
            _selectedLocation = location;
          });
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context, _selectedLocation);
        },
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        label: const Text("Confirm"),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
