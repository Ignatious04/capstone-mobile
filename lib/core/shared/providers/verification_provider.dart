import 'package:capstone/core/enums/audit_action_enum.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/enums/verification_status_enum.dart';
import 'package:capstone/core/shared/providers/audit_log_repository_provider.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/core/utilities/formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fails closed: no user data yet counts as not verified.
final isVerifiedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentAuthenticatedUserProvider).value;
  return user?.verificationStatus == VerificationStatusEnum.approved;
});

final minuteTickProvider = StreamProvider.autoDispose<DateTime>(
  (ref) => Stream.periodic(const Duration(minutes: 1), (_) => DateTime.now()),
);

class NotVerifiedException implements Exception {
  @override
  String toString() => "Your account must be verified before you can send reports.";
}

class ReportingRestrictedException implements Exception {
  @override
  String toString() => "Online reporting is restricted on your account.";
}

/// Returns true if the user may send online reports.
/// Otherwise shows why and returns false.
Future<bool> ensureVerified(BuildContext context, WidgetRef ref) async {
  if (ref.read(isVerifiedProvider)) return true;

  final l10n = AppLocalizations.of(context)!;

  final status = ref.read(currentAuthenticatedUserProvider).value?.verificationStatus;
  final rejected = status == VerificationStatusEnum.rejected;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: TitleText(value: rejected ? l10n.verificationNotVerified : l10n.verificationPendingTitle),
      content: BodyText(
        value: rejected ? l10n.verificationRejectedBody : l10n.verificationPendingBody,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.ok)),
      ],
    ),
  );
  return false;
}

Future<void> _showNotice(BuildContext context, String title, String body) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: TitleText(value: title),
      content: BodyText(value: body),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.ok)),
      ],
    ),
  );
}

/// Returns true if the user may send online reports: verified, not restricted,
/// and has seen the prank warning once after a new strike.
/// Evaluated at call time (not a cached provider) so an expired suspension
/// unlocks without an app restart.
Future<bool> ensureCanReport(BuildContext context, WidgetRef ref) async {
  if (!await ensureVerified(context, ref)) return false;
  if (!context.mounted) return false;

  final user = ref.read(currentAuthenticatedUserProvider).value;
  if (user == null) return false;
  final l10n = AppLocalizations.of(context)!;

  if (user.isReportingRestricted) {
    ref.read(auditLogRepositoryProvider).log(
      AuditAction.reportBlockedRestricted,
      metadata: {'strikes': user.prankStrikes},
    );
    final until = user.reportingSuspendedUntil;
    final locale = Localizations.localeOf(context).languageCode;
    await _showNotice(
      context,
      l10n.reportingRestrictedTitle,
      user.reportingBanned || until == null
          ? l10n.reportingBannedBody
          : l10n.reportingSuspendedBody(
              Formatter.formatDateTime(DateTime.fromMillisecondsSinceEpoch(until), locale),
            ),
    );
    return false;
  }

  // Show the warning once per new strike (covers strike 1, which doesn't suspend).
  final prefs = await SharedPreferences.getInstance();
  final key = 'prankWarningAck_${user.userID}';
  if ((prefs.getInt(key) ?? 0) < user.prankStrikes) {
    if (!context.mounted) return false;
    await _showNotice(context, l10n.prankWarningTitle, l10n.prankWarningBody);
    await prefs.setInt(key, user.prankStrikes);
  }
  return true;
}
