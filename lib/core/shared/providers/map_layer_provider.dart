import 'package:capstone/core/enums/map_layer_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kMapLayerKey = 'map_layer';

/// The currently selected base map layer, shared by every map in the app
/// (public user and responder) and remembered between launches.
class MapLayerNotifier extends Notifier<MapLayerEnum> {
  @override
  MapLayerEnum build() {
    _load();
    return MapLayerEnum.standard;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kMapLayerKey);
    final layer = MapLayerEnum.values.where((l) => l.name == saved).firstOrNull;
    if (layer != null && layer != state) state = layer;
  }

  Future<void> set(MapLayerEnum layer) async {
    state = layer;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMapLayerKey, layer.name);
  }
}

final mapLayerProvider = NotifierProvider<MapLayerNotifier, MapLayerEnum>(
  MapLayerNotifier.new,
);