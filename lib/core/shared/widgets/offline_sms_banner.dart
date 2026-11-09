import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/providers/connectivity_stream_provider.dart';
import 'package:capstone/core/shared/providers/main_tab_provider.dart';
import 'package:capstone/core/shared/providers/verification_provider.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OfflineSmsBanner extends ConsumerWidget {
  const OfflineSmsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final results = ref.watch(connectivityStreamProvider).value;
    final isOffline = results != null && results.contains(ConnectivityResult.none);

    // Unverified users can't send SMS reports; VerificationBanner already explains why.
    if (!isOffline || !ref.watch(isVerifiedProvider)) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.lighterDeepOrange,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.themeColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => ref.read(mainTabProvider.notifier).set(kGuidanceTabIndex),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.sms_outlined, color: AppColors.themeColor, size: 25),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BodyText(value: l10n.offlineSmsBanner),
                    const SizedBox(height: 4),
                    LabelText(value: l10n.offlineSmsBannerAction),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.themeColor),
            ],
          ),
        ),
      ),
    );
  }
}