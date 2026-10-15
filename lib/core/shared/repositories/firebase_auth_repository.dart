import 'package:capstone/core/enums/audit_action_enum.dart';
import 'package:capstone/core/exceptions/auth_exception.dart';
import 'package:capstone/core/shared/repositories/audit_log_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthRepository {
  final FirebaseAuth firebaseAuth;
  final AuditLogRepository _audit;
  FirebaseAuthRepository(this.firebaseAuth, this._audit);

  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();
  bool get hasPasswordProvider => currentUser?.providerData.any((p) => p.providerId == 'password') ?? false;
  bool isPhoneVerified(String e164Number) => e164Number.isNotEmpty && currentUser?.phoneNumber == e164Number;

  String? get verifiedPhoneNumber => currentUser?.phoneNumber;

  static const _webClientId = '794094290044-usbas125bbnvnlb9rm69nrcfm2uenhl7.apps.googleusercontent.com';
  static Future<void>? _googleInit;

  // GoogleSignIn.initialize() must be called exactly once per app run.
  Future<void> _ensureGoogleInitialized() {
    return _googleInit ??= GoogleSignIn.instance.initialize(serverClientId: _webClientId);
  }

  /// Returns null if the user closes the Google account picker.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();
      final googleUser = await GoogleSignIn.instance.authenticate();
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw AuthException(AuthErrorCode.googleFailed);
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final result = await firebaseAuth.signInWithCredential(credential);
      _audit.log(
        AuditAction.login,
        metadata: {
          'method': 'google',
          'isNewUser': result.additionalUserInfo?.isNewUser ?? false,
        },
      );
      return result;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      debugPrint('Google sign-in error: ${e.code} ${e.description}');
      throw AuthException(AuthErrorCode.googleFailed);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    try {
      return await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _audit.log(AuditAction.login, metadata: {"method": "password"});
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  /// Email/password accounts only.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw AuthException(AuthErrorCode.noUser);
      if (!hasPasswordProvider || user.email == null) {
        throw AuthException(AuthErrorCode.googleNoPassword);
      }

      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: user.email!, password: currentPassword),
      );
      await user.updatePassword(newPassword);
      _audit.log(AuditAction.passwordChanged);
    } on FirebaseAuthException catch (e) {
      _audit.log(AuditAction.passwordChangeFailed, metadata: {"reason": e.code});
      throw _mapAuthError(e);
    }
  }

  /// Re-verifies the user before a sensitive action. Pass [password] for
  /// email accounts; leave it null for Google accounts (shows the Google picker).
  /// Returns false if the user cancelled the picker.
  Future<bool> reauthenticate({String? password}) async {
    try {
      final user = currentUser;
      if (user == null) throw AuthException(AuthErrorCode.noUser);

      if (hasPasswordProvider) {
        if (password == null || password.isEmpty) {
          throw AuthException(AuthErrorCode.enterPassword);
        }
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: user.email!, password: password),
        );
        return true;
      }

      await _ensureGoogleInitialized();
      final googleUser = await GoogleSignIn.instance.authenticate();
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) throw AuthException(AuthErrorCode.googleFailed);

      await user.reauthenticateWithCredential(GoogleAuthProvider.credential(idToken: idToken));
      return true;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return false;
      throw AuthException(AuthErrorCode.googleFailed);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<void> reauthenticateWithPhone({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw AuthException(AuthErrorCode.noUser);

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await user.reauthenticateWithCredential(credential);
      _audit.log(AuditAction.reactivationOtpVerified);
    } on FirebaseAuthException catch (e) {
      _audit.log(AuditAction.reactivationOtpFailed, metadata: {'reason': e.code});
      throw _mapAuthError(e);
    }
  }

  Exception _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'invalid-email':
        return AuthException(AuthErrorCode.invalidEmail);
      case 'invalid-credential':
      case 'wrong-password':
        return AuthException(AuthErrorCode.wrongCredentials);
      case 'too-many-requests':
        return AuthException(AuthErrorCode.tooManyAttempts);
      case 'network-request-failed':
        return AuthException(AuthErrorCode.noInternet);
      case 'invalid-verification-code':
        return AuthException(AuthErrorCode.invalidCode);
      case 'invalid-phone-number':
        return AuthException(AuthErrorCode.invalidPhone);
      case 'credential-already-in-use':
        return AuthException(AuthErrorCode.phoneInUse);
      case 'quota-exceeded':
        return AuthException(AuthErrorCode.smsQuota);
      case 'provider-already-linked':
        return AuthException(AuthErrorCode.phoneAlreadyVerified);
      case 'account-exists-with-different-credential':
        return AuthException(AuthErrorCode.emailExists);
      case 'weak-password':
        return AuthException(AuthErrorCode.weakPassword);
      case 'requires-recent-login':
        return AuthException(AuthErrorCode.requiresRecentLogin);
      case 'user-mismatch':
        return AuthException(AuthErrorCode.wrongGoogleAccount);
      default:
        return AuthException(AuthErrorCode.generic);
    }
  }

  Future<void> signOut({AuditAction auditAction = AuditAction.logout}) async {
    await _audit.logAndWait(auditAction);
    try {
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }

    // Best-effort: never let this block logging out.
    try {
      await _ensureGoogleInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(
        email: email,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw AuthException(AuthErrorCode.noUser);
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      await user.delete();
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw AuthException(AuthErrorCode.noUser);
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<void> reloadUser() async {
    try {
      await currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential credential) onVerificationCompleted,
    required void Function(FirebaseAuthException e) onVerificationFailed,
    required void Function(String verificationId, int? resendToken) onCodeSent,
  }) async {
    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }

  Future<void> linkPhoneCredential(PhoneAuthCredential credential) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw AuthException(AuthErrorCode.noUser);
      }
      await user.linkWithCredential(credential);
      _audit.log(AuditAction.phoneLinked);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }
}
