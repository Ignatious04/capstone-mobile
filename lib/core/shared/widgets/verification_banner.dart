import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/enums/verification_status_enum.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/providers/verification_provider.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerificationBanner extends ConsumerWidget {
  const VerificationBanner({super.key});

  String _timeAgo(AppLocalizations l10n, int millis) {
    final diff = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(millis));
    if (diff.inMinutes < 1) return l10n.timeJustNow;
    if (diff.inHours < 1) return l10n.timeMinutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.timeHoursAgo(diff.inHours);
    return l10n.timeDaysAgo(diff.inDays);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    if (ref.watch(isVerifiedProvider)) return const SizedBox.shrink();

    final user = ref.watch(currentAuthenticatedUserProvider).value;
    final submittedAt = user?.verificationSubmittedAt;
    final isPending = user?.verificationStatus == VerificationStatusEnum.pending;

    if (isPending && submittedAt != null) ref.watch(minuteTickProvider);

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
          const Icon(
            Icons.lock_outline,
            color: Colors.deepOrange,
            size: 25,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyText(
                  value: l10n.verificationBannerBody,
                ),
                if (isPending && submittedAt != null) LabelText(value: l10n.verificationSubmittedAgo(_timeAgo(l10n, submittedAt))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
