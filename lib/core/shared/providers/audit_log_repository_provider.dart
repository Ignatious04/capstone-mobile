import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/firestore_provider.dart';
import 'package:capstone/core/shared/repositories/audit_log_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final auditLogRepositoryProvider = Provider<AuditLogRepository>((ref) {
  return AuditLogRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});
