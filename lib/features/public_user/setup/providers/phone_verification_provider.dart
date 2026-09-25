// lib/features/setup/providers/phone_verification_provider.dart
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/user_repository_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhoneVerificationProvider {
  final String? verificationId;
  final bool codeSent;
  final bool isVerified;
  final AsyncValue<void> status;

  const PhoneVerificationProvider({
    this.verificationId,
    this.codeSent = false,
    this.isVerified = false,
    this.status = const AsyncData(null),
  });

  PhoneVerificationProvider copyWith({
    String? verificationId,
    bool? codeSent,
    bool? isVerified,
    AsyncValue<void>? status,
  }) {
    return PhoneVerificationProvider(
      verificationId: verificationId ?? this.verificationId,
      codeSent: codeSent ?? this.codeSent,
      isVerified: isVerified ?? this.isVerified,
      status: status ?? this.status,
    );
  }
}

final phoneVerificationProvider = NotifierProvider<PhoneVerificationNotifier, PhoneVerificationProvider>(
  PhoneVerificationNotifier.new,
);

class PhoneVerificationNotifier extends Notifier<PhoneVerificationProvider> {
  @override
  PhoneVerificationProvider build() => const PhoneVerificationProvider();

  Future<void> sendCode(String e164PhoneNumber) async {
    state = state.copyWith(status: const AsyncLoading());

    try {
      await ref
          .read(firebaseAuthRepositoryProvider)
          .verifyPhoneNumber(
            phoneNumber: e164PhoneNumber,
            onVerificationCompleted: (credential) async {
              await ref.read(firebaseAuthRepositoryProvider).linkPhoneCredential(credential);
              await ref.read(userRepositoryProvider).updateUser(
                ref.read(firebaseAuthProvider).currentUser!.uid,
                {"isContactNumberVerified": true},
              );
              state = state.copyWith(isVerified: true, status: const AsyncData(null));
            },
            onVerificationFailed: (e) {
              state = state.copyWith(status: AsyncError(e, StackTrace.current));
            },
            onCodeSent: (id, resendToken) {
              state = state.copyWith(
                verificationId: id,
                codeSent: true,
                status: const AsyncData(null),
              );
            },
          );
    } catch (e, st) {
      state = state.copyWith(status: AsyncError(e, st));
    }
  }

  Future<void> verifyCode(String smsCode) async {
    if (state.verificationId == null) return;

    state = state.copyWith(status: const AsyncLoading());

    final result = await AsyncValue.guard(() async {
      final credential = PhoneAuthProvider.credential(
        verificationId: state.verificationId!,
        smsCode: smsCode,
      );
      await ref.read(firebaseAuthRepositoryProvider).linkPhoneCredential(credential);
      await ref.read(userRepositoryProvider).updateUser(
        ref.read(firebaseAuthProvider).currentUser!.uid,
        {"isContactNumberVerified": true},
      );
    });

    state = state.copyWith(status: result, isVerified: result is AsyncData);
  }

  void reset() {
    state = const PhoneVerificationProvider();
  }
}
