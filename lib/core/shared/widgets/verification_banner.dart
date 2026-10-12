import 'package:capstone/core/shared/providers/verification_provider.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerificationBanner extends ConsumerWidget {
  const VerificationBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(isVerifiedProvider)) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lighterDeepOrange,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepOrange),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline, color: Colors.deepOrange),
          SizedBox(width: 10),
          Expanded(
            child: BodyText(
              value: "Reporting unlocks once your account is verified. You can still call emergency services.",
            ),
          ),
        ],
      ),
    );
  }
}