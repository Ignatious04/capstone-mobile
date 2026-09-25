import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReactivationPhoneState {
  final String? verificationId;
  final bool codeSent;
  final AsyncValue<void> status;

  const ReactivationPhoneState({
    this.verificationId,
    this.codeSent = false,
    this.status = const AsyncData(null),
  });

  ReactivationPhoneState copyWith({
    String? verificationId,
    bool? codeSent,
    AsyncValue<void>? status,
  }) {
    return ReactivationPhoneState(
      verificationId: verificationId ?? this.verificationId,
      codeSent: codeSent ?? this.codeSent,
      status: status ?? this.status,
    );
  }
}

final reactivationPhoneProvider = NotifierProvider<ReactivationPhoneNotifier, ReactivationPhoneState>(
  ReactivationPhoneNotifier.new,
);

class ReactivationPhoneNotifier extends Notifier<ReactivationPhoneState> {
  @override
  ReactivationPhoneState build() => const ReactivationPhoneState();

  Future<void> sendCode(String e164PhoneNumber) async {
    state = state.copyWith(status: const AsyncLoading());

    try {
      await ref
          .read(firebaseAuthRepositoryProvider)
          .verifyPhoneNumber(
            phoneNumber: e164PhoneNumber,
            onVerificationCompleted: (credential) async {
              if (credential.smsCode != null) {
                await verifyCode(credential.smsCode!);
              }
            },
            onVerificationFailed: (e) {
              state = state.copyWith(status: AsyncError(e, StackTrace.current));
            },
            onCodeSent: (id, resendToken) {
              state = state.copyWith(verificationId: id, codeSent: true, status: const AsyncData(null));
            },
          );
    } catch (e, st) {
      state = state.copyWith(status: AsyncError(e, st));
    }
  }

  /// Proves the caller still has this phone number. Does NOT reactivate the
  /// account by itself - the caller reactivates separately once this succeeds.
  Future<void> verifyCode(String smsCode) async {
    if (state.verificationId == null) return;
    state = state.copyWith(status: const AsyncLoading());

    final result = await AsyncValue.guard(() async {
      await ref
          .read(firebaseAuthRepositoryProvider)
          .reauthenticateWithPhone(verificationId: state.verificationId!, smsCode: smsCode);
    });

    state = state.copyWith(status: result);
  }

  void reset() => state = const ReactivationPhoneState();
}