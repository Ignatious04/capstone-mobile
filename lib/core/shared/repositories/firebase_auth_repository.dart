import 'package:capstone/core/exceptions/auth_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthRepository {
  final FirebaseAuth firebaseAuth;
  FirebaseAuthRepository(this.firebaseAuth);

  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

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

  Exception _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-email':
        return AuthException("Please check the format of your email address");
      case 'invalid-credential':
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
