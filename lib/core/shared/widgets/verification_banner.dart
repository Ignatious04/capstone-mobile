import 'package:capstone/core/enums/verification_status_enum.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/providers/verification_provider.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerificationBanner extends ConsumerWidget {
  const VerificationBanner({super.key});

  String _timeAgo(int millis) {
    final diff = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(millis));
    if (diff.inMinutes < 1) return "just now";
    if (diff.inHours < 1) return "${diff.inMinutes} min ago";
    if (diff.inDays < 1) return "${diff.inHours} hr ago";
    return "${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(isVerifiedProvider)) return const SizedBox.shrink();

    final user = ref.watch(currentAuthenticatedUserProvider).value;
    final submittedAt = user?.verificationSubmittedAt;
    final isPending = user?.verificationStatus == VerificationStatusEnum.pending;

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
          const Icon(Icons.lock_outline, color: Colors.deepOrange),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BodyText(
                  value: "Reporting unlocks once your account is verified. You can still call emergency services.",
                ),
                if (isPending && submittedAt != null) BodyText(value: "Submitted ${_timeAgo(submittedAt)}."),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
