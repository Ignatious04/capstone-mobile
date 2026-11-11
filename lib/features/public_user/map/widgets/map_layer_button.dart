import 'package:capstone/core/enums/map_layer_enums.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/providers/map_layer_provider.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Small floating button that opens a menu to switch the base map layer.
class MapLayerButton extends ConsumerWidget {
  const MapLayerButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.watch(mapLayerProvider);

    String label(MapLayerEnum layer) => switch (layer) {
          MapLayerEnum.standard => l10n.mapLayerDefault,
          MapLayerEnum.satellite => l10n.mapLayerSatellite,
        };

    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(12),
      color: AppColors.bgWhiteLight,
      child: PopupMenuButton<MapLayerEnum>(
        tooltip: l10n.mapLayers,
        initialValue: current,
        onSelected: (layer) => ref.read(mapLayerProvider.notifier).set(layer),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        itemBuilder: (_) => [
          for (final layer in MapLayerEnum.values)
            PopupMenuItem(
              value: layer,
              child: Row(
                children: [
                  Icon(
                    layer == current ? Icons.radio_button_checked : Icons.radio_button_off,
                    size: 20,
                    color: AppColors.themeColor,
                  ),
                  const SizedBox(width: 10),
                  Text(label(layer)),
                ],
              ),
            ),
        ],
        child: const SizedBox(
          width: 50,
          height: 50,
          child: Icon(Icons.layers, color: AppColors.themeColor, size: 25),
        ),
      ),
    );
  }
}