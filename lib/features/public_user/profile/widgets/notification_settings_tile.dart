import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/services/push_notification_service.dart';
import 'package:capstone/core/shared/providers/location_provider.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationSettingsTile extends ConsumerStatefulWidget {
  const NotificationSettingsTile({super.key});

  @override
  ConsumerState<NotificationSettingsTile> createState() => _NotificationSettingsTileState();
}

class _NotificationSettingsTileState extends ConsumerState<NotificationSettingsTile> with WidgetsBindingObserver {
  bool? _enabled; // null until the first check
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh(); // back from system Settings
  }

  Future<void> _refresh() async {
    try {
      final enabled = await ref.read(pushNotificationServiceProvider).areNotificationsEnabled();
      if (mounted) setState(() => _enabled = enabled);
    } catch (e) {
      debugPrint('notification status check failed: $e');
    }
  }

  Future<void> _onChanged(bool wantOn) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      // Geolocator's openAppSettings opens this app's system settings page on
      // both platforms; the person taps "Notifications" from there.
      final openSettings = ref.read(locationServiceProvider).openAppSettings;

      if (wantOn) {
        final result = await ref.read(pushNotificationServiceProvider).requestNotificationPermission();
        if (!result.enabled && !result.promptShown) await openSettings();
      } else {
        await openSettings(); // the OS owns this permission; apps can't revoke it
      }
    } catch (e) {
      debugPrint('notification toggle failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final on = _enabled ?? false;

    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.bgWhiteLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.cardBorder),
      ),
      child: SwitchListTile(
        activeThumbColor: AppColors.themeColor,
        inactiveThumbColor: AppColors.blackTextMuted,
        inactiveTrackColor: AppColors.cardBorder,
        hoverColor: Colors.transparent,
        secondary: const Icon(Icons.notifications_outlined, size: 25),
        title: BodyText(value: l10n.notifications),
        subtitle: BodyText(value: on ? l10n.notificationsOn : l10n.notificationsOff, isBold: true),
        value: on,
        onChanged: (_enabled == null || _busy) ? null : _onChanged,
      ),
    );
  }
}
