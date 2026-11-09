import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/providers/verification_provider.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/core/utilities/formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportingRestrictionBanner extends ConsumerWidget {
  const ReportingRestrictionBanner({super.key});

  String _remaining(AppLocalizations l10n, int untilMillis) {
    final ms = untilMillis - DateTime.now().millisecondsSinceEpoch;
    final total = (ms / 60000).ceil().clamp(1, 1 << 30); // round up to whole minutes
    final days = total ~/ 1440;
    final hours = (total % 1440) ~/ 60;
    final minutes = total % 60;
    if (days > 0) return l10n.durationDaysHours(days, hours);
    if (hours > 0) return l10n.durationHoursMinutes(hours, minutes);
    return l10n.durationMinutes(minutes);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentAuthenticatedUserProvider).value;
    if (user == null || !user.isReportingRestricted) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final until = user.reportingSuspendedUntil;
    final isBan = user.reportingBanned || until == null;

    // Re-evaluates every minute so the countdown stays fresh and the banner
    // disappears once the suspension ends.
    if (!isBan) ref.watch(minuteTickProvider);

    final locale = Localizations.localeOf(context).languageCode;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lighterRed,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger),
      ),
      child: Row(
        children: [
          const Icon(Icons.block, color: AppColors.danger, size: 25),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyText(value: l10n.reportingRestrictedTitle, isBold: true),
                const SizedBox(height: 4),
                if (isBan)
                  BodyText(value: l10n.reportingBannedBody)
                else ...[
                  BodyText(value: l10n.reportingBannerRemaining(_remaining(l10n, until))),
                  const SizedBox(height: 4),
                  LabelText(
                    value: l10n.reportingBannerResumes(
                      Formatter.formatDateTime(DateTime.fromMillisecondsSinceEpoch(until), locale),
                    ),
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