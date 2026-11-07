import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/providers/main_tab_provider.dart';
import 'package:capstone/core/shared/providers/report_provider.dart';
import 'package:capstone/core/shared/providers/verification_provider.dart';
import 'package:capstone/core/shared/widgets/custom_alert_dialog.dart';
import 'package:capstone/features/public_user/pre_call_guidance/providers/guidance_provider.dart';
import 'package:capstone/features/public_user/pre_call_guidance/views/pre_call_guidance_page_view.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool> isDeviceOffline() async {
  final results = await Connectivity().checkConnectivity();
  return results.contains(ConnectivityResult.none);
}

/// Same steps the Guidance tab's service buttons run.
void startGuidanceFlow(BuildContext context, WidgetRef ref, ServiceTypeEnum type) {
  ref.read(reportProvider.notifier).setIncidentType(type);
  ref.read(guidanceProvider.notifier).loadQuestions(type);
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const PreCallGuidancePageView()),
  );
}

/// Asks whether to fall back to SMS. Shared by the timeout handlers.
Future<bool> confirmSmsFallback(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final ok = await showConfirmationDialog(
    context,
    title: l10n.attention,
    content: l10n.smsFallbackPrompt,
    confirmText: l10n.useSmsReport,
  );
  return ok == true;
}

/// Returns true when the device is offline, meaning the CALLER MUST STOP:
/// the user has already been shown a dialog or moved to the SMS flow.
/// Pass [type] to jump straight into that service's guidance questions,
/// or omit it to just switch to the Guidance tab.
Future<bool> handleOffline(
  BuildContext context,
  WidgetRef ref, {
  ServiceTypeEnum? type,
}) async {
  if (!await isDeviceOffline()) return false;
  if (!context.mounted) return true;

  // SMS reports are verified-only, so don't offer a path that fails at the end.
  if (!await ensureVerified(context, ref)) return true;
  if (!context.mounted) return true;

  if (!await confirmSmsFallback(context)) return true;
  if (!context.mounted) return true;

  if (type != null) {
    startGuidanceFlow(context, ref, type);
  } else {
    ref.read(mainTabProvider.notifier).set(kGuidanceTabIndex);
  }
  return true;
}