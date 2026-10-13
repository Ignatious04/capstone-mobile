import 'package:capstone/core/enums/verification_status_enum.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Returns true if the user may send online reports.
/// Otherwise shows why and returns false.
Future<bool> ensureVerified(BuildContext context, WidgetRef ref) async {
  if (ref.read(isVerifiedProvider)) return true;

  final status = ref.read(currentAuthenticatedUserProvider).value?.verificationStatus;
  final rejected = status == VerificationStatusEnum.rejected;

  await showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: TitleText(value: rejected ? "Account not verified" : "Verification pending"),
      content: BodyText(
        value: rejected
            ? "Your account couldn't be verified, so reporting is unavailable. You can still call emergency services."
            : "Reporting unlocks once an administrator verifies your account. You can still call emergency services in the meantime.",
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
      ],
    ),
  );
  return false;
}
