import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/enums/rejection_code_enum.dart';
import 'package:capstone/core/shared/models/user_model.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/core/utilities/call_launcher.dart';
import 'package:capstone/features/public_user/setup/views/setup_screen_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RejectedScreen extends ConsumerWidget {
  const RejectedScreen({super.key, required this.user});

  final UserModel user;

  Future<void> _call911(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      await launchPhoneCall('911');
    } catch (_) {
      if (context.mounted) {
        CustomSnackbarHelper.show(context, text: l10n.dialerError);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final note = user.rejectionReason;
    final hasNote = note != null && note.trim().isNotEmpty;
    final headline = user.rejectionCode?.message(l10n) ??
        (hasNote ? null : l10n.rejectedCouldntVerifySome);
    final hasDetails = headline != null || hasNote;
    const kMaxResubmissions = 3;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.error_outline, size: 50, color: Colors.deepOrange),
                const SizedBox(height: 10),
                TitleText(
                  value: l10n.rejectedCouldntVerifyAccount,
                  alignment: TextAlign.center,
                ),
                const SizedBox(height: 10),
                BodyText(
                  value: user.canResubmit
                      ? l10n.rejectedNeedsUpdate
                      : l10n.rejectedUnableToApprove,
                  color: Colors.black54,
                  alignment: TextAlign.center,
                ),
                if (hasDetails) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.deepOrange.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodyText(value: l10n.reason, isBold: true),
                        const SizedBox(height: 6),
                        if (headline != null) BodyText(value: headline),
                        if (headline != null && note != null && note.trim().isNotEmpty) const SizedBox(height: 6),
                        if (note != null && note.trim().isNotEmpty) BodyText(value: note),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                if (user.canResubmit && user.resubmissionCount < kMaxResubmissions)
                  CustomElevatedButton(
                    value: l10n.updateMyInformation,
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SetupScreenPageView(resubmitFrom: user)),
                    ),
                  )
                else
                  BodyText(
                    value: l10n.contactAdmin,
                    color: Colors.black54,
                    alignment: TextAlign.center,
                  ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _call911(context),
                  icon: const Icon(Icons.call, color: Colors.red),
                  label: BodyText(value: l10n.call911, color: Colors.red, isBold: true),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(14),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => ref.read(firebaseAuthRepositoryProvider).signOut(),
                  child: Text(l10n.logout),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
