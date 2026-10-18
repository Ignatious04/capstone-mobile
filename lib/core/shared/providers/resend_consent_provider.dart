import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final resendConsentProvider = NotifierProvider<ResendConsentNotifier, AsyncValue<void>>(
  ResendConsentNotifier.new,
);

class ResendConsentNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> resend() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await FirebaseFunctions.instance.httpsCallable('resendGuardianConsent').call();
    });
  }
}