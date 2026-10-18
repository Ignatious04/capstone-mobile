import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/utilities/call_launcher.dart';
import 'package:capstone/features/public_user/main/providers/nearest_emergency_services_provider.dart';
import 'package:capstone/features/public_user/map/providers/contact_number_repository_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> callNearestService(
  BuildContext context,
  WidgetRef ref,
  ServiceTypeEnum type,
) async {
  // Live nearest service first, cached number as the fallback
  String? number = ref.read(nearestEmergencyServicesProvider).value?[type]?.contactNumber;
  if (number == null || number.isEmpty) {
    number = await ref.read(contactNumberRepositoryProvider).getNumber(type);
  }

  if (!context.mounted) return;
  final l10n = AppLocalizations.of(context)!;

  if (number == null || number.isEmpty) {
    CustomSnackbarHelper.show(context, text: l10n.noContactNumber);
    return;
  }

  try {
    await launchPhoneCall(number);
  } catch (_) {
    if (!context.mounted) return;
    CustomSnackbarHelper.show(context, text: l10n.dialerError);
  }
}
