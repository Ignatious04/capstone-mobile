import 'package:capstone/core/enums/consent_status_enum.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/providers/resend_consent_provider.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/providers/verification_provider.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConsentBanner extends ConsumerWidget {
  const ConsentBanner({super.key});

  // Display only; the server enforces the real limits.
  static const _cooldown = Duration(hours: 1);
  static const _maxSends = 5;

  String _mask(String email) {
    final at = email.indexOf('@');
    if (at < 2) return email;
    return '${email[0]}***${email.substring(at)}';
  }

  String _errorMessage(AppLocalizations l10n, Object error) {
    if (error is FirebaseFunctionsException && error.code == 'resource-exhausted') {
      return error.message == 'limit-reached' ? l10n.consentResendLimit : l10n.consentResendTooSoon;
    }
    return l10n.somethingWentWrong;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentAuthenticatedUserProvider).value;
    final status = user?.consentStatus;

    ref.listen<AsyncValue<void>>(resendConsentProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => CustomSnackbarHelper.show(context, text: _errorMessage(l10n, error)),
      );
      if (previous?.isLoading == true && next.hasValue) {
        CustomSnackbarHelper.show(context, text: l10n.consentResendSent);
      }
    });

    if (user == null || (status != ConsentStatusEnum.pending && status != ConsentStatusEnum.revoked)) {
      return const SizedBox.shrink();
    }

    final isPending = status == ConsentStatusEnum.pending;
    if (isPending) ref.watch(minuteTickProvider); // keeps the countdown fresh

    final message = isPending
        ? l10n.consentBannerPending(_mask(user.guardianContact))
        : l10n.consentBannerRevoked;

    final nextSendAt = (user.consentLastSentAt ?? 0) + _cooldown.inMilliseconds;
    final remaining = Duration(milliseconds: nextSendAt - DateTime.now().millisecondsSinceEpoch);
    final limitReached = user.consentSendCount >= _maxSends;
    final isSending = ref.watch(resendConsentProvider).isLoading;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lighterDeepOrange,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepOrange),
      ),
      child: Row(
        children: [
          const Icon(Icons.family_restroom, color: Colors.deepOrange, size: 25),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyText(value: message),
                if (isPending) ...[
                  const SizedBox(height: 4),
                  if (limitReached)
                    LabelText(value: l10n.consentResendLimit)
                  else if (remaining > Duration.zero)
                    LabelText(value: l10n.consentResendWait(remaining.inMinutes + 1))
                  else
                    TextButton(
                      onPressed: isSending ? null : () => ref.read(resendConsentProvider.notifier).resend(),
                      child: Text(isSending ? l10n.loading : l10n.consentResend),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}