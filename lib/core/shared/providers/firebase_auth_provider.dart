import 'package:capstone/core/shared/providers/audit_log_repository_provider.dart';
import 'package:capstone/core/shared/repositories/firebase_auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firebaseAuthRepositoryProvider = Provider<FirebaseAuthRepository>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthRepository(firebaseAuth, ref.watch(auditLogRepositoryProvider));
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(firebaseAuthRepositoryProvider);
  return authService.authStateChanges;
});
