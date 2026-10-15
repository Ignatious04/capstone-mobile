import 'package:capstone/core/l10n/app_localizations.dart';

enum AuthErrorCode {
  googleFailed,
  noUser,
  googleNoPassword,
  enterPassword,
  invalidEmail,
  wrongCredentials,
  tooManyAttempts,
  noInternet,
  invalidCode,
  invalidPhone,
  phoneInUse,
  smsQuota,
  phoneAlreadyVerified,
  emailExists,
  weakPassword,
  requiresRecentLogin,
  wrongGoogleAccount,
  verifyPhoneFirst,
  ongoingReport,
  generic,
}

class AuthException implements Exception {
  const AuthException(this.code);

  final AuthErrorCode code;

  /// Text shown to the user, in the app's current language.
  String localized(AppLocalizations l10n) {
    switch (code) {
      case AuthErrorCode.googleFailed:
        return l10n.authGoogleFailed;
      case AuthErrorCode.noUser:
        return l10n.authNoUser;
      case AuthErrorCode.googleNoPassword:
        return l10n.authGoogleNoPassword;
      case AuthErrorCode.enterPassword:
        return l10n.authEnterPassword;
      case AuthErrorCode.invalidEmail:
        return l10n.authInvalidEmail;
      case AuthErrorCode.wrongCredentials:
        return l10n.authWrongCredentials;
      case AuthErrorCode.tooManyAttempts:
        return l10n.authTooManyAttempts;
      case AuthErrorCode.noInternet:
        return l10n.authNoInternet;
      case AuthErrorCode.invalidCode:
        return l10n.authInvalidCode;
      case AuthErrorCode.invalidPhone:
        return l10n.authInvalidPhone;
      case AuthErrorCode.phoneInUse:
        return l10n.authPhoneInUse;
      case AuthErrorCode.smsQuota:
        return l10n.authSmsQuota;
      case AuthErrorCode.phoneAlreadyVerified:
        return l10n.authPhoneAlreadyVerified;
      case AuthErrorCode.emailExists:
        return l10n.authEmailExists;
      case AuthErrorCode.weakPassword:
        return l10n.authWeakPassword;
      case AuthErrorCode.requiresRecentLogin:
        return l10n.authRequiresRecentLogin;
      case AuthErrorCode.wrongGoogleAccount:
        return l10n.authWrongGoogleAccount;
      case AuthErrorCode.verifyPhoneFirst:
        return l10n.deactivateVerifyPhoneFirst;
      case AuthErrorCode.ongoingReport:
        return l10n.deactivateOngoingReport;
      case AuthErrorCode.generic:
        return l10n.somethingWentWrong;
    }
  }

  /// For logs only (profile_screen's debugPrint). Never show this to users.
  String get message => code.name;

  @override
  String toString() => code.name;
}
