import 'package:capstone/core/exceptions/auth_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthRepository {
  final FirebaseAuth firebaseAuth;
  FirebaseAuthRepository(this.firebaseAuth);

  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();
  bool get hasPasswordProvider => currentUser?.providerData.any((p) => p.providerId == 'password') ?? false;

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
        throw AuthException('Google sign-in failed. Please try again.');
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      return await firebaseAuth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      debugPrint('Google sign-in error: ${e.code} ${e.description}');
      throw AuthException('Google sign-in failed. Please try again.');
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
      return await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
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
      if (user == null) throw AuthException('No user is currently signed in.');
      if (!hasPasswordProvider || user.email == null) {
        throw AuthException('This account signs in with Google and has no password.');
      }

      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: user.email!, password: currentPassword),
      );
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  /// Re-verifies the user before a sensitive action. Pass [password] for
  /// email accounts; leave it null for Google accounts (shows the Google picker).
  /// Returns false if the user cancelled the picker.
  Future<bool> reauthenticate({String? password}) async {
    try {
      final user = currentUser;
      if (user == null) throw AuthException('No user is currently signed in.');

      if (hasPasswordProvider) {
        if (password == null || password.isEmpty) {
          throw AuthException('Please enter your password.');
        }
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: user.email!, password: password),
        );
        return true;
      }

      await _ensureGoogleInitialized();
      final googleUser = await GoogleSignIn.instance.authenticate();
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) throw AuthException('Google sign-in failed. Please try again.');

      await user.reauthenticateWithCredential(GoogleAuthProvider.credential(idToken: idToken));
      return true;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return false;
      throw AuthException('Google sign-in failed. Please try again.');
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
      if (user == null) throw AuthException('No user is currently signed in.');

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  Exception _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'invalid-email':
        return AuthException("Please check the format of your email address");
      case 'invalid-credential':
      case 'wrong-password':
        return AuthException('Incorrect email or password.');
      case 'too-many-requests':
        return AuthException('Too many attempts. Try again later.');
      case 'network-request-failed':
        return AuthException('No internet connection.');
      case 'invalid-verification-code':
        return AuthException('Invalid code. Please try again.');
      case 'invalid-phone-number':
        return AuthException('Please enter a valid phone number.');
      case 'credential-already-in-use':
        return AuthException('This phone number is already linked to another account.');
      case 'quota-exceeded':
        return AuthException('SMS quota exceeded. Please try again later.');
      case 'provider-already-linked':
        return AuthException('This account already has a verified phone number.');
      case 'account-exists-with-different-credential':
        return AuthException('An account already exists with this email. Log in with your email and password instead.');
      case 'weak-password':
        return AuthException('Password must be at least 6 characters.');
      case 'requires-recent-login':
        return AuthException('Please log in again to continue.');
      case 'user-mismatch':
        return AuthException('Please choose the same Google account you signed up with.');
      default:
        return AuthException('Something went wrong. Please try again.');
    }
  }

  Future<void> signOut() async {
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
        throw AuthException('No user is currently signed in.');
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
        throw AuthException('No user is currently signed in.');
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
        throw AuthException('No user is currently signed in.');
      }
      await user.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }
}
