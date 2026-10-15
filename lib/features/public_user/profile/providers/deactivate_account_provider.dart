import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/exceptions/auth_exception.dart';
import 'package:capstone/core/services/push_notification_service.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/user_repository_provider.dart';
import 'package:capstone/core/shared/providers/report_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deactivateAccountProvider = NotifierProvider<DeactivateAccountNotifier, AsyncValue<void>>(
  DeactivateAccountNotifier.new,
);

class DeactivateAccountNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// true = deactivated and signed out, false = cancelled or failed (check state).
  Future<bool> deactivate({String? password}) async {
    state = const AsyncLoading();
    var deactivated = false;

    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(firebaseAuthRepositoryProvider);
      final userID = authRepository.currentUser!.uid;

      // 0. Must have a verified number before you're allowed to deactivate at all.
      final user = await ref.read(userRepositoryProvider).getUser(userID);
      if (user == null || !user.isContactNumberVerified) {
        throw AuthException(AuthErrorCode.verifyPhoneFirst);
      }

      // 1. Don't cut someone off from status updates mid-emergency.
      final reports = await ref.read(reportRepositoryProvider).getReports(userID).first;
      if (reports.any((report) => report.status != ReportStatusEnum.resolved)) {
        throw AuthException(AuthErrorCode.ongoingReport);
      }

      // 2. Prove it's them (password, or the Google picker for Google accounts).
      final verified = await authRepository.reauthenticate(password: password);
      if (!verified) return;

      // 3. Flag the account, then sign out.
      await ref.read(userRepositoryProvider).setDeactivated(userID, isDeactivated: true);
      await ref.read(pushNotificationServiceProvider).clearToken(userID);
      await authRepository.signOut();
      deactivated = true;
    });

    return deactivated && !state.hasError;
  }

  Future<void> reactivate() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final userID = ref.read(firebaseAuthRepositoryProvider).currentUser!.uid;
      await ref.read(userRepositoryProvider).setDeactivated(userID, isDeactivated: false);
    });
  }
}
