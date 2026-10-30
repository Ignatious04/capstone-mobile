import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fil.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('fil')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Capstone'**
  String get appTitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Emergency App'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fast and reliable emergency response at your fingertips.'**
  String get welcomeSubtitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @middleName.
  ///
  /// In en, this message translates to:
  /// **'Middle Name'**
  String get middleName;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get birthDate;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @emergencyServices.
  ///
  /// In en, this message translates to:
  /// **'Emergency Services'**
  String get emergencyServices;

  /// No description provided for @nearestEmergencyServices.
  ///
  /// In en, this message translates to:
  /// **'Nearest Emergency Services'**
  String get nearestEmergencyServices;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @reportEmergency.
  ///
  /// In en, this message translates to:
  /// **'Report Emergency'**
  String get reportEmergency;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get selectLocation;

  /// No description provided for @attachImage.
  ///
  /// In en, this message translates to:
  /// **'Attach Image'**
  String get attachImage;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @additionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get additionalInformation;

  /// No description provided for @victims.
  ///
  /// In en, this message translates to:
  /// **'Victims'**
  String get victims;

  /// No description provided for @addVictim.
  ///
  /// In en, this message translates to:
  /// **'Add Victim'**
  String get addVictim;

  /// No description provided for @victimName.
  ///
  /// In en, this message translates to:
  /// **'Victim Name'**
  String get victimName;

  /// No description provided for @victimAge.
  ///
  /// In en, this message translates to:
  /// **'Victim Age'**
  String get victimAge;

  /// No description provided for @victimCondition.
  ///
  /// In en, this message translates to:
  /// **'Victim Condition'**
  String get victimCondition;

  /// No description provided for @preCallGuidance.
  ///
  /// In en, this message translates to:
  /// **'Pre-Call Guidance'**
  String get preCallGuidance;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @medicalInformation.
  ///
  /// In en, this message translates to:
  /// **'Medical Information'**
  String get medicalInformation;

  /// No description provided for @bloodType.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get bloodType;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @medicalConditions.
  ///
  /// In en, this message translates to:
  /// **'Medical Conditions'**
  String get medicalConditions;

  /// No description provided for @emergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts'**
  String get emergencyContacts;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @responderHome.
  ///
  /// In en, this message translates to:
  /// **'Responder Home'**
  String get responderHome;

  /// No description provided for @verificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Verification Status'**
  String get verificationStatus;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String fieldRequired(String field);

  /// No description provided for @invalidPhone10.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit number'**
  String get invalidPhone10;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordMin6.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMin6;

  /// No description provided for @newPasswordMustDiffer.
  ///
  /// In en, this message translates to:
  /// **'New password must be different'**
  String get newPasswordMustDiffer;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @sendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Send verification code'**
  String get sendVerificationCode;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get verifyCode;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get enterCode;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @verifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get verifying;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get checking;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updating;

  /// No description provided for @deactivating.
  ///
  /// In en, this message translates to:
  /// **'Deactivating...'**
  String get deactivating;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noDescriptionProvided.
  ///
  /// In en, this message translates to:
  /// **'No description provided.'**
  String get noDescriptionProvided;

  /// No description provided for @notAnswered.
  ///
  /// In en, this message translates to:
  /// **'Not answered'**
  String get notAnswered;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you wish to log out?'**
  String get logoutConfirm;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @unnamedResponder.
  ///
  /// In en, this message translates to:
  /// **'Unnamed responder'**
  String get unnamedResponder;

  /// No description provided for @unnamedVictim.
  ///
  /// In en, this message translates to:
  /// **'Unnamed victim'**
  String get unnamedVictim;

  /// No description provided for @noAttachments.
  ///
  /// In en, this message translates to:
  /// **'No attachments provided.'**
  String get noAttachments;

  /// No description provided for @noAdditionalInfo.
  ///
  /// In en, this message translates to:
  /// **'No additional information provided.'**
  String get noAdditionalInfo;

  /// No description provided for @noVictimInfo.
  ///
  /// In en, this message translates to:
  /// **'No victim information provided.'**
  String get noVictimInfo;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @contactNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get contactNumber;

  /// No description provided for @homeAddress.
  ///
  /// In en, this message translates to:
  /// **'Home Address'**
  String get homeAddress;

  /// No description provided for @sex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get sex;

  /// No description provided for @nationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationality;

  /// No description provided for @civilStatus.
  ///
  /// In en, this message translates to:
  /// **'Civil Status'**
  String get civilStatus;

  /// No description provided for @religion.
  ///
  /// In en, this message translates to:
  /// **'Religion'**
  String get religion;

  /// No description provided for @houseNumber.
  ///
  /// In en, this message translates to:
  /// **'House No.'**
  String get houseNumber;

  /// No description provided for @street.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get street;

  /// No description provided for @barangay.
  ///
  /// In en, this message translates to:
  /// **'Barangay'**
  String get barangay;

  /// No description provided for @idType.
  ///
  /// In en, this message translates to:
  /// **'ID Type'**
  String get idType;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @incidentLocation.
  ///
  /// In en, this message translates to:
  /// **'Incident Location'**
  String get incidentLocation;

  /// No description provided for @referenceNumber.
  ///
  /// In en, this message translates to:
  /// **'Reference Number'**
  String get referenceNumber;

  /// No description provided for @submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submitted;

  /// No description provided for @reported.
  ///
  /// In en, this message translates to:
  /// **'Reported'**
  String get reported;

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @backOnline.
  ///
  /// In en, this message translates to:
  /// **'Back online'**
  String get backOnline;

  /// No description provided for @offlineMessage.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Some features may be limited.'**
  String get offlineMessage;

  /// No description provided for @backOnlineMessage.
  ///
  /// In en, this message translates to:
  /// **'Back online.'**
  String get backOnlineMessage;

  /// No description provided for @guidance.
  ///
  /// In en, this message translates to:
  /// **'Guidance'**
  String get guidance;

  /// No description provided for @activeCase.
  ///
  /// In en, this message translates to:
  /// **'Active Case'**
  String get activeCase;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Mobile Emergency Access System'**
  String get appTagline;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get loginWelcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to your account'**
  String get loginSubtitle;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully!'**
  String get loginSuccess;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountPrompt;

  /// No description provided for @createOne.
  ///
  /// In en, this message translates to:
  /// **'Create one'**
  String get createOne;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset successful! Please check your email.'**
  String get resetEmailSent;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @signUpWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get signUpWithGoogle;

  /// No description provided for @registration.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get registration;

  /// No description provided for @userCredentials.
  ///
  /// In en, this message translates to:
  /// **'User Credentials'**
  String get userCredentials;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the Terms and Conditions'**
  String get agreeToTerms;

  /// No description provided for @acknowledgePrivacy.
  ///
  /// In en, this message translates to:
  /// **'I have read and acknowledge the app\'s Privacy Policy.'**
  String get acknowledgePrivacy;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @legalLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load this document.'**
  String get legalLoadError;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to {email}. Tap the link, then come back and press Continue.'**
  String verifyEmailBody(String email);

  /// No description provided for @verifiedContinue.
  ///
  /// In en, this message translates to:
  /// **'I\'ve verified, continue'**
  String get verifiedContinue;

  /// No description provided for @stillNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Still not verified yet — check your inbox.'**
  String get stillNotVerified;

  /// No description provided for @verificationEmailResent.
  ///
  /// In en, this message translates to:
  /// **'Verification email resent.'**
  String get verificationEmailResent;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get resendEmail;

  /// No description provided for @resendAvailableShortly.
  ///
  /// In en, this message translates to:
  /// **'Resend available shortly'**
  String get resendAvailableShortly;

  /// No description provided for @deactivatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account is deactivated'**
  String get deactivatedTitle;

  /// No description provided for @deactivatedBody.
  ///
  /// In en, this message translates to:
  /// **'Your profile and reports are safe. Reactivate to use the app and send reports again.'**
  String get deactivatedBody;

  /// No description provided for @reactivateAccount.
  ///
  /// In en, this message translates to:
  /// **'Reactivate Account'**
  String get reactivateAccount;

  /// No description provided for @signedOutTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ve been signed out'**
  String get signedOutTitle;

  /// No description provided for @signedOutBody.
  ///
  /// In en, this message translates to:
  /// **'Your account was signed in on another device, so this device was logged out. If this wasn\'t you, change your password after logging back in.'**
  String get signedOutBody;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @rejectedCouldntVerifySome.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t verify some of your information.'**
  String get rejectedCouldntVerifySome;

  /// No description provided for @rejectedCouldntVerifyAccount.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t verify your account'**
  String get rejectedCouldntVerifyAccount;

  /// No description provided for @rejectedNeedsUpdate.
  ///
  /// In en, this message translates to:
  /// **'An administrator reviewed your information and needs you to update it.'**
  String get rejectedNeedsUpdate;

  /// No description provided for @rejectedUnableToApprove.
  ///
  /// In en, this message translates to:
  /// **'An administrator reviewed your information and was unable to approve your account.'**
  String get rejectedUnableToApprove;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @updateMyInformation.
  ///
  /// In en, this message translates to:
  /// **'Update my information'**
  String get updateMyInformation;

  /// No description provided for @contactAdmin.
  ///
  /// In en, this message translates to:
  /// **'Please contact your local administrator for assistance.'**
  String get contactAdmin;

  /// No description provided for @call911.
  ///
  /// In en, this message translates to:
  /// **'Call 911'**
  String get call911;

  /// No description provided for @dialerError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the dialer.'**
  String get dialerError;

  /// No description provided for @dialerLaunchError.
  ///
  /// In en, this message translates to:
  /// **'Could not launch dialer for {number}'**
  String dialerLaunchError(String number);

  /// No description provided for @smsLaunchError.
  ///
  /// In en, this message translates to:
  /// **'Could not launch messaging app for {number}'**
  String smsLaunchError(String number);

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to continue.'**
  String get locationPermissionRequired;

  /// No description provided for @locationPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission has been permanently denied. Please enable it in Settings.'**
  String get locationPermanentlyDenied;

  /// No description provided for @locationServicesOff.
  ///
  /// In en, this message translates to:
  /// **'Please enable Location Services to continue.'**
  String get locationServicesOff;

  /// No description provided for @quickReporting.
  ///
  /// In en, this message translates to:
  /// **'Quick Reporting'**
  String get quickReporting;

  /// No description provided for @quickCrime.
  ///
  /// In en, this message translates to:
  /// **'Crime'**
  String get quickCrime;

  /// No description provided for @quickReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Send a quick {label} report?'**
  String quickReportTitle(String label);

  /// No description provided for @quickReportBody.
  ///
  /// In en, this message translates to:
  /// **'This immediately sends your current location as an emergency report. Only use this for real emergencies.'**
  String get quickReportBody;

  /// No description provided for @responseTimeNotice.
  ///
  /// In en, this message translates to:
  /// **'Angeles City\'s declared emergency response time is 10–15 minutes; please note that actual response time may vary depending on responder availability, traffic, and the nature of each case.'**
  String get responseTimeNotice;

  /// No description provided for @reportSent.
  ///
  /// In en, this message translates to:
  /// **'Report sent!'**
  String get reportSent;

  /// No description provided for @reportSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report sent successfully!'**
  String get reportSentSuccess;

  /// No description provided for @reportSendError.
  ///
  /// In en, this message translates to:
  /// **'An error has occurred while trying to send your report!'**
  String get reportSendError;

  /// No description provided for @call911Button.
  ///
  /// In en, this message translates to:
  /// **'CALL 911'**
  String get call911Button;

  /// No description provided for @nearbyServices.
  ///
  /// In en, this message translates to:
  /// **'Nearby Services'**
  String get nearbyServices;

  /// No description provided for @serviceMap.
  ///
  /// In en, this message translates to:
  /// **'Service Map'**
  String get serviceMap;

  /// No description provided for @findNearbyServices.
  ///
  /// In en, this message translates to:
  /// **'Find nearby emergency services'**
  String get findNearbyServices;

  /// No description provided for @locationUnavailableMsg.
  ///
  /// In en, this message translates to:
  /// **'Unable to determine your location.'**
  String get locationUnavailableMsg;

  /// No description provided for @locationCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 location} other{{count} locations}}'**
  String locationCount(int count);

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'Get directions'**
  String get getDirections;

  /// No description provided for @directionsError.
  ///
  /// In en, this message translates to:
  /// **'Could not open directions to {location}'**
  String directionsError(String location);

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get noNotifications;

  /// No description provided for @deleteNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete notification?'**
  String get deleteNotificationTitle;

  /// No description provided for @deleteNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'This will remove it from your notification history.'**
  String get deleteNotificationBody;

  /// No description provided for @notificationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted'**
  String get notificationDeleted;

  /// No description provided for @deleteNotification.
  ///
  /// In en, this message translates to:
  /// **'Delete notification'**
  String get deleteNotification;

  /// No description provided for @guidanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let us route you to the right service'**
  String get guidanceSubtitle;

  /// No description provided for @currentSituation.
  ///
  /// In en, this message translates to:
  /// **'What is your current situation?'**
  String get currentSituation;

  /// No description provided for @areYouHurt.
  ///
  /// In en, this message translates to:
  /// **'Are you hurt?'**
  String get areYouHurt;

  /// No description provided for @lawViolation.
  ///
  /// In en, this message translates to:
  /// **'Is there a violation of the law?'**
  String get lawViolation;

  /// No description provided for @ongoingFire.
  ///
  /// In en, this message translates to:
  /// **'Is there an ongoing fire?'**
  String get ongoingFire;

  /// No description provided for @callNearestService.
  ///
  /// In en, this message translates to:
  /// **'Call nearest related service'**
  String get callNearestService;

  /// No description provided for @noContactNumber.
  ///
  /// In en, this message translates to:
  /// **'No contact number available for this service.'**
  String get noContactNumber;

  /// No description provided for @noIncidentSelected.
  ///
  /// In en, this message translates to:
  /// **'No incident type selected.'**
  String get noIncidentSelected;

  /// No description provided for @noCachedContact.
  ///
  /// In en, this message translates to:
  /// **'No cached contact number available for offline reporting. Please connect to the internet at least once.'**
  String get noCachedContact;

  /// No description provided for @guidanceQConscious.
  ///
  /// In en, this message translates to:
  /// **'Is the person conscious?'**
  String get guidanceQConscious;

  /// No description provided for @guidanceQLifeThreatening.
  ///
  /// In en, this message translates to:
  /// **'Are there life-threatening injuries?'**
  String get guidanceQLifeThreatening;

  /// No description provided for @guidanceQIntentional.
  ///
  /// In en, this message translates to:
  /// **'Is their current condition intentional?'**
  String get guidanceQIntentional;

  /// No description provided for @guidanceQSuspectPresent.
  ///
  /// In en, this message translates to:
  /// **'Is the suspect present?'**
  String get guidanceQSuspectPresent;

  /// No description provided for @guidanceQWeapons.
  ///
  /// In en, this message translates to:
  /// **'Are there weapons involved?'**
  String get guidanceQWeapons;

  /// No description provided for @guidanceQSomeoneInjured.
  ///
  /// In en, this message translates to:
  /// **'Is someone injured?'**
  String get guidanceQSomeoneInjured;

  /// No description provided for @guidanceQTrapped.
  ///
  /// In en, this message translates to:
  /// **'Are there people trapped inside?'**
  String get guidanceQTrapped;

  /// No description provided for @guidanceQFireSpreading.
  ///
  /// In en, this message translates to:
  /// **'Is the fire spreading?'**
  String get guidanceQFireSpreading;

  /// No description provided for @guidanceCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Guidance Complete'**
  String get guidanceCompleteTitle;

  /// No description provided for @guidanceCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'Your pre-call guidance has been completed. You may now submit your report to the appropriate agency.'**
  String get guidanceCompleteBody;

  /// No description provided for @gettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting your location...'**
  String get gettingLocation;

  /// No description provided for @weakGps.
  ///
  /// In en, this message translates to:
  /// **'Weak GPS signal (±{meters} m). Add a landmark or adjust your pin so responders can find you.'**
  String weakGps(int meters);

  /// No description provided for @landmarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Landmark'**
  String get landmarkLabel;

  /// No description provided for @landmarkHint.
  ///
  /// In en, this message translates to:
  /// **'Landmark, building, floor…'**
  String get landmarkHint;

  /// No description provided for @adjustLocation.
  ///
  /// In en, this message translates to:
  /// **'Adjust location on map'**
  String get adjustLocation;

  /// No description provided for @locationAdjusted.
  ///
  /// In en, this message translates to:
  /// **'Location adjusted ✓'**
  String get locationAdjusted;

  /// No description provided for @submitReportPrompt.
  ///
  /// In en, this message translates to:
  /// **'Do you wish to submit this report?'**
  String get submitReportPrompt;

  /// No description provided for @offlineSmsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Due to the loss of internet connection, this report will send through the SMS, proceed?'**
  String get offlineSmsPrompt;

  /// No description provided for @locationUnavailableBang.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable!'**
  String get locationUnavailableBang;

  /// No description provided for @guidanceSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Guidance report submitted successfully!'**
  String get guidanceSubmitted;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// No description provided for @reportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you need'**
  String get reportsSubtitle;

  /// No description provided for @noReports.
  ///
  /// In en, this message translates to:
  /// **'No reports yet.'**
  String get noReports;

  /// No description provided for @viewReport.
  ///
  /// In en, this message translates to:
  /// **'View Report'**
  String get viewReport;

  /// No description provided for @whileYouWait.
  ///
  /// In en, this message translates to:
  /// **'While you wait'**
  String get whileYouWait;

  /// No description provided for @emergencyType.
  ///
  /// In en, this message translates to:
  /// **'Emergency Type'**
  String get emergencyType;

  /// No description provided for @incidentType.
  ///
  /// In en, this message translates to:
  /// **'Incident Type'**
  String get incidentType;

  /// No description provided for @responder.
  ///
  /// In en, this message translates to:
  /// **'Responder'**
  String get responder;

  /// No description provided for @incidentAndResponderLocation.
  ///
  /// In en, this message translates to:
  /// **'Incident & Responder Location'**
  String get incidentAndResponderLocation;

  /// No description provided for @incidentInformation.
  ///
  /// In en, this message translates to:
  /// **'Incident Information'**
  String get incidentInformation;

  /// No description provided for @preCallReportNote.
  ///
  /// In en, this message translates to:
  /// **'This report was submitted through the pre-call guidance module.'**
  String get preCallReportNote;

  /// No description provided for @questionsAndAnswers.
  ///
  /// In en, this message translates to:
  /// **'Questions and Answers'**
  String get questionsAndAnswers;

  /// No description provided for @reportedLocation.
  ///
  /// In en, this message translates to:
  /// **'Reported Location'**
  String get reportedLocation;

  /// No description provided for @estimatedArrival.
  ///
  /// In en, this message translates to:
  /// **'Estimated Arrival'**
  String get estimatedArrival;

  /// No description provided for @responderOnScene.
  ///
  /// In en, this message translates to:
  /// **'Responder is on scene'**
  String get responderOnScene;

  /// No description provided for @distanceAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} away (estimate)'**
  String distanceAway(String distance);

  /// No description provided for @etaArrivingNow.
  ///
  /// In en, this message translates to:
  /// **'Arriving now'**
  String get etaArrivingNow;

  /// No description provided for @etaLessThanMin.
  ///
  /// In en, this message translates to:
  /// **'Less than 1 min'**
  String get etaLessThanMin;

  /// No description provided for @etaMinutes.
  ///
  /// In en, this message translates to:
  /// **'~{minutes} min'**
  String etaMinutes(int minutes);

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: '**
  String get statusLabel;

  /// No description provided for @emergencyReport.
  ///
  /// In en, this message translates to:
  /// **'Emergency Report'**
  String get emergencyReport;

  /// No description provided for @requiredInformation.
  ///
  /// In en, this message translates to:
  /// **'Required Information'**
  String get requiredInformation;

  /// No description provided for @requiredNote.
  ///
  /// In en, this message translates to:
  /// **'Note: required fields are denoted by an asterisk (*)'**
  String get requiredNote;

  /// No description provided for @isThisEmergency.
  ///
  /// In en, this message translates to:
  /// **'Is this an emergency?'**
  String get isThisEmergency;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @nonEmergency.
  ///
  /// In en, this message translates to:
  /// **'Non-emergency'**
  String get nonEmergency;

  /// No description provided for @concernType.
  ///
  /// In en, this message translates to:
  /// **'Concern Type'**
  String get concernType;

  /// No description provided for @concernNoiseComplaint.
  ///
  /// In en, this message translates to:
  /// **'Noise complaint'**
  String get concernNoiseComplaint;

  /// No description provided for @concernLostItem.
  ///
  /// In en, this message translates to:
  /// **'Lost/stolen item'**
  String get concernLostItem;

  /// No description provided for @concernMinorDispute.
  ///
  /// In en, this message translates to:
  /// **'Minor dispute'**
  String get concernMinorDispute;

  /// No description provided for @concernSuspiciousActivity.
  ///
  /// In en, this message translates to:
  /// **'Suspicious activity'**
  String get concernSuspiciousActivity;

  /// No description provided for @concernVandalism.
  ///
  /// In en, this message translates to:
  /// **'Vandalism'**
  String get concernVandalism;

  /// No description provided for @concernRequestForReport.
  ///
  /// In en, this message translates to:
  /// **'Request for a police report'**
  String get concernRequestForReport;

  /// No description provided for @concernOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get concernOther;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @changeLocation.
  ///
  /// In en, this message translates to:
  /// **'Change location'**
  String get changeLocation;

  /// No description provided for @optionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Optional Information'**
  String get optionalInformation;

  /// No description provided for @victimInformation.
  ///
  /// In en, this message translates to:
  /// **'Victim Information'**
  String get victimInformation;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @addAttachment.
  ///
  /// In en, this message translates to:
  /// **'Add attachment'**
  String get addAttachment;

  /// No description provided for @removeAttachment.
  ///
  /// In en, this message translates to:
  /// **'Remove attachment'**
  String get removeAttachment;

  /// No description provided for @unableToGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Unable to get your current location.'**
  String get unableToGetLocation;

  /// No description provided for @submitConfirmNote.
  ///
  /// In en, this message translates to:
  /// **'By submitting, you confirm that this report is accurate.'**
  String get submitConfirmNote;

  /// No description provided for @safetyProfile.
  ///
  /// In en, this message translates to:
  /// **'Safety Profile'**
  String get safetyProfile;

  /// No description provided for @viewManageAccount.
  ///
  /// In en, this message translates to:
  /// **'View and manage your account'**
  String get viewManageAccount;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @updatePersonalInformation.
  ///
  /// In en, this message translates to:
  /// **'Update Personal Information'**
  String get updatePersonalInformation;

  /// No description provided for @updateInformation.
  ///
  /// In en, this message translates to:
  /// **'Update Information'**
  String get updateInformation;

  /// No description provided for @userIdLabel.
  ///
  /// In en, this message translates to:
  /// **'User ID: {id}'**
  String userIdLabel(String id);

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @updateInfoPrompt.
  ///
  /// In en, this message translates to:
  /// **'Do you wish to update your personal information?'**
  String get updateInfoPrompt;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note:'**
  String get noteLabel;

  /// No description provided for @reverifyNote.
  ///
  /// In en, this message translates to:
  /// **'You will have to re-verify your number, confirm?'**
  String get reverifyNote;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @verifyPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify Phone Number'**
  String get verifyPhoneNumber;

  /// No description provided for @verifyPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Required before you can deactivate your account'**
  String get verifyPhoneRequired;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated.'**
  String get passwordUpdated;

  /// No description provided for @deactivateAccount.
  ///
  /// In en, this message translates to:
  /// **'Deactivate Account'**
  String get deactivateAccount;

  /// No description provided for @deactivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Deactivate your account?'**
  String get deactivateTitle;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// No description provided for @deactivateHeading.
  ///
  /// In en, this message translates to:
  /// **'Deactivate your account'**
  String get deactivateHeading;

  /// No description provided for @deactivateBody.
  ///
  /// In en, this message translates to:
  /// **'You won\'t be able to use the app or send reports until you reactivate. Your profile and past reports are kept, and you can reactivate any time by logging in again. You can still call emergency hotlines from your phone.'**
  String get deactivateBody;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @googleConfirmNote.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be asked to confirm with your Google account.'**
  String get googleConfirmNote;

  /// No description provided for @deactivateMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Deactivate My Account'**
  String get deactivateMyAccount;

  /// No description provided for @accountDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deactivated.'**
  String get accountDeactivated;

  /// No description provided for @deactivateVerifyPhoneFirst.
  ///
  /// In en, this message translates to:
  /// **'Please verify your phone number before deactivating your account.'**
  String get deactivateVerifyPhoneFirst;

  /// No description provided for @deactivateOngoingReport.
  ///
  /// In en, this message translates to:
  /// **'You have an ongoing report. You can deactivate once it is resolved.'**
  String get deactivateOngoingReport;

  /// No description provided for @phoneVerifiedOk.
  ///
  /// In en, this message translates to:
  /// **'Phone number verified!'**
  String get phoneVerifiedOk;

  /// No description provided for @phoneVerifyIntro.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a code to {phone} to verify it\'s still yours. This lets you deactivate and later reactivate your account securely.'**
  String phoneVerifyIntro(String phone);

  /// No description provided for @verifyItsYou.
  ///
  /// In en, this message translates to:
  /// **'Verify It\'s You'**
  String get verifyItsYou;

  /// No description provided for @sendingCodeTo.
  ///
  /// In en, this message translates to:
  /// **'Sending a code to {phone}...'**
  String sendingCodeTo(String phone);

  /// No description provided for @enterCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the code we sent to {phone}.'**
  String enterCodeSentTo(String phone);

  /// No description provided for @verifyAndReactivate.
  ///
  /// In en, this message translates to:
  /// **'Verify & Reactivate'**
  String get verifyAndReactivate;

  /// No description provided for @accountReactivated.
  ///
  /// In en, this message translates to:
  /// **'Your account has been reactivated.'**
  String get accountReactivated;

  /// No description provided for @invalidOrExpiredCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired code.'**
  String get invalidOrExpiredCode;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get hello;

  /// No description provided for @welcomeSetup.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start off by setting up your account.'**
  String get welcomeSetup;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @updateYourInformation.
  ///
  /// In en, this message translates to:
  /// **'Update Your Information'**
  String get updateYourInformation;

  /// No description provided for @setupSafetyProfile.
  ///
  /// In en, this message translates to:
  /// **'Set up your safety profile'**
  String get setupSafetyProfile;

  /// No description provided for @fixFlaggedDetails.
  ///
  /// In en, this message translates to:
  /// **'Fix the details we flagged'**
  String get fixFlaggedDetails;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @resubmit.
  ///
  /// In en, this message translates to:
  /// **'Resubmit'**
  String get resubmit;

  /// No description provided for @resubmitted.
  ///
  /// In en, this message translates to:
  /// **'Resubmitted'**
  String get resubmitted;

  /// No description provided for @resubmittedBody.
  ///
  /// In en, this message translates to:
  /// **'Your information is back in the review queue. We\'ll notify you of the result.'**
  String get resubmittedBody;

  /// No description provided for @registerPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Register Phone Number'**
  String get registerPhoneNumber;

  /// No description provided for @phoneVerified.
  ///
  /// In en, this message translates to:
  /// **'Phone number verified'**
  String get phoneVerified;

  /// No description provided for @pleaseVerifyPhone.
  ///
  /// In en, this message translates to:
  /// **'Please verify your phone number'**
  String get pleaseVerifyPhone;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhoto;

  /// No description provided for @idPhoto.
  ///
  /// In en, this message translates to:
  /// **'ID photo'**
  String get idPhoto;

  /// No description provided for @tapToTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to take photo'**
  String get tapToTakePhoto;

  /// No description provided for @medicalInfoOptional.
  ///
  /// In en, this message translates to:
  /// **'Medical Info (Optional)'**
  String get medicalInfoOptional;

  /// No description provided for @medicalInfoHelp.
  ///
  /// In en, this message translates to:
  /// **'This information helps emergency responders provide better care. All fields are optional.'**
  String get medicalInfoHelp;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightCm;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @areYouVaccinated.
  ///
  /// In en, this message translates to:
  /// **'Are you vaccinated?'**
  String get areYouVaccinated;

  /// No description provided for @vaccineType.
  ///
  /// In en, this message translates to:
  /// **'Vaccine Type'**
  String get vaccineType;

  /// No description provided for @vaccineDate.
  ///
  /// In en, this message translates to:
  /// **'Vaccine Date'**
  String get vaccineDate;

  /// No description provided for @personalProfileSummary.
  ///
  /// In en, this message translates to:
  /// **'Personal Profile Summary'**
  String get personalProfileSummary;

  /// No description provided for @attention.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get attention;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'REMINDER: Saup Angeles is a guidance and reporting tool only. It does not replace direct emergency calls to 911 or local hotlines.'**
  String get reminder;

  /// No description provided for @userValidation.
  ///
  /// In en, this message translates to:
  /// **'User Validation'**
  String get userValidation;

  /// No description provided for @documentIdType.
  ///
  /// In en, this message translates to:
  /// **'Document ID Type'**
  String get documentIdType;

  /// No description provided for @alignId.
  ///
  /// In en, this message translates to:
  /// **'Align your ID inside the frame'**
  String get alignId;

  /// No description provided for @captureId.
  ///
  /// In en, this message translates to:
  /// **'Capture ID'**
  String get captureId;

  /// No description provided for @retakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake photo'**
  String get retakePhoto;

  /// No description provided for @idNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'ID Number: {number}'**
  String idNumberLabel(String number);

  /// No description provided for @serverUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the server. Check your connection and try again.'**
  String get serverUnreachable;

  /// No description provided for @idTypePhilsys.
  ///
  /// In en, this message translates to:
  /// **'National ID (PhilSys)'**
  String get idTypePhilsys;

  /// No description provided for @idTypeDriversLicense.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s License'**
  String get idTypeDriversLicense;

  /// No description provided for @idTypePassport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get idTypePassport;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Account and Safety Profile Saved'**
  String get onboardingTitle;

  /// No description provided for @onboardingBody.
  ///
  /// In en, this message translates to:
  /// **'Your personal information has been successfully saved and secured. You\'re now ready to access emergency services through the application.'**
  String get onboardingBody;

  /// No description provided for @proceedToHome.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Home'**
  String get proceedToHome;

  /// No description provided for @noActiveCase.
  ///
  /// In en, this message translates to:
  /// **'No active case'**
  String get noActiveCase;

  /// No description provided for @noActiveCaseHint.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be notified here when a case is assigned to you.'**
  String get noActiveCaseHint;

  /// No description provided for @noLocationOnReport.
  ///
  /// In en, this message translates to:
  /// **'No location on this report'**
  String get noLocationOnReport;

  /// No description provided for @reporterAttachments.
  ///
  /// In en, this message translates to:
  /// **'Reporter Attachments'**
  String get reporterAttachments;

  /// No description provided for @responderAttachments.
  ///
  /// In en, this message translates to:
  /// **'Responder Attachments'**
  String get responderAttachments;

  /// No description provided for @holdToUpdate.
  ///
  /// In en, this message translates to:
  /// **'Hold for 2 seconds to update'**
  String get holdToUpdate;

  /// No description provided for @enRoute.
  ///
  /// In en, this message translates to:
  /// **'En Route'**
  String get enRoute;

  /// No description provided for @arrivedOnScene.
  ///
  /// In en, this message translates to:
  /// **'Arrived on Scene'**
  String get arrivedOnScene;

  /// No description provided for @resolveCase.
  ///
  /// In en, this message translates to:
  /// **'Resolve Case'**
  String get resolveCase;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get addImage;

  /// No description provided for @uploadError.
  ///
  /// In en, this message translates to:
  /// **'Could not upload the image. Check your connection and try again.'**
  String get uploadError;

  /// No description provided for @historySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your resolved cases'**
  String get historySubtitle;

  /// No description provided for @noResolvedCases.
  ///
  /// In en, this message translates to:
  /// **'No resolved cases yet'**
  String get noResolvedCases;

  /// No description provided for @caseDetails.
  ///
  /// In en, this message translates to:
  /// **'Case Details'**
  String get caseDetails;

  /// No description provided for @resolvedAt.
  ///
  /// In en, this message translates to:
  /// **'Resolved {date}'**
  String resolvedAt(String date);

  /// No description provided for @responderProfile.
  ///
  /// In en, this message translates to:
  /// **'Responder Profile'**
  String get responderProfile;

  /// No description provided for @viewYourAccount.
  ///
  /// In en, this message translates to:
  /// **'View your account'**
  String get viewYourAccount;

  /// No description provided for @responderCode.
  ///
  /// In en, this message translates to:
  /// **'Responder Code'**
  String get responderCode;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @reportStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get reportStatusPending;

  /// No description provided for @reportStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get reportStatusAccepted;

  /// No description provided for @reportStatusDispatched.
  ///
  /// In en, this message translates to:
  /// **'Dispatched'**
  String get reportStatusDispatched;

  /// No description provided for @reportStatusOnScene.
  ///
  /// In en, this message translates to:
  /// **'On Scene'**
  String get reportStatusOnScene;

  /// No description provided for @reportStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get reportStatusResolved;

  /// No description provided for @serviceMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get serviceMedical;

  /// No description provided for @servicePolice.
  ///
  /// In en, this message translates to:
  /// **'Police'**
  String get servicePolice;

  /// No description provided for @serviceFire.
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get serviceFire;

  /// No description provided for @rejectionIdUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Your ID photo could not be read clearly.'**
  String get rejectionIdUnreadable;

  /// No description provided for @rejectionSelfieMismatch.
  ///
  /// In en, this message translates to:
  /// **'Your selfie did not match your ID.'**
  String get rejectionSelfieMismatch;

  /// No description provided for @rejectionIncompleteInfo.
  ///
  /// In en, this message translates to:
  /// **'Some of your information is missing or incorrect.'**
  String get rejectionIncompleteInfo;

  /// No description provided for @faceNoFace.
  ///
  /// In en, this message translates to:
  /// **'No face detected. Please retake the photo.'**
  String get faceNoFace;

  /// No description provided for @faceMultiple.
  ///
  /// In en, this message translates to:
  /// **'Multiple faces detected. Please retake alone.'**
  String get faceMultiple;

  /// No description provided for @faceNotFacing.
  ///
  /// In en, this message translates to:
  /// **'Please face the camera directly.'**
  String get faceNotFacing;

  /// No description provided for @faceEyesClosed.
  ///
  /// In en, this message translates to:
  /// **'Your eyes appear closed. Please retake.'**
  String get faceEyesClosed;

  /// No description provided for @idCaptureUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read the ID number. Retake with better lighting.'**
  String get idCaptureUnreadable;

  /// No description provided for @idCaptureDuplicate.
  ///
  /// In en, this message translates to:
  /// **'This ID is already registered to another account.'**
  String get idCaptureDuplicate;

  /// No description provided for @sexMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get sexMale;

  /// No description provided for @sexFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get sexFemale;

  /// No description provided for @nationalityFilipino.
  ///
  /// In en, this message translates to:
  /// **'Filipino'**
  String get nationalityFilipino;

  /// No description provided for @nationalityAmerican.
  ///
  /// In en, this message translates to:
  /// **'American'**
  String get nationalityAmerican;

  /// No description provided for @civilSingle.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get civilSingle;

  /// No description provided for @civilMarried.
  ///
  /// In en, this message translates to:
  /// **'Married'**
  String get civilMarried;

  /// No description provided for @civilWidowed.
  ///
  /// In en, this message translates to:
  /// **'Widowed'**
  String get civilWidowed;

  /// No description provided for @religionIglesia.
  ///
  /// In en, this message translates to:
  /// **'Iglesia ni Cristo'**
  String get religionIglesia;

  /// No description provided for @religionIslam.
  ///
  /// In en, this message translates to:
  /// **'Islam'**
  String get religionIslam;

  /// No description provided for @religionCatholic.
  ///
  /// In en, this message translates to:
  /// **'Roman Catholic'**
  String get religionCatholic;

  /// No description provided for @vaccineAntiRabies.
  ///
  /// In en, this message translates to:
  /// **'Anti-Rabies'**
  String get vaccineAntiRabies;

  /// No description provided for @tipMedical1.
  ///
  /// In en, this message translates to:
  /// **'Keep the person calm and as still as possible.'**
  String get tipMedical1;

  /// No description provided for @tipMedical2.
  ///
  /// In en, this message translates to:
  /// **'Apply steady pressure to any bleeding wound with a clean cloth.'**
  String get tipMedical2;

  /// No description provided for @tipMedical3.
  ///
  /// In en, this message translates to:
  /// **'Do not give food or water if they are unconscious or having trouble breathing.'**
  String get tipMedical3;

  /// No description provided for @tipMedical4.
  ///
  /// In en, this message translates to:
  /// **'Loosen tight clothing and keep them warm.'**
  String get tipMedical4;

  /// No description provided for @tipMedical5.
  ///
  /// In en, this message translates to:
  /// **'If they stop breathing and you know CPR, begin chest compressions.'**
  String get tipMedical5;

  /// No description provided for @tipFire1.
  ///
  /// In en, this message translates to:
  /// **'Get everyone out of the building and stay out.'**
  String get tipFire1;

  /// No description provided for @tipFire2.
  ///
  /// In en, this message translates to:
  /// **'Do not use elevators; take the stairs if evacuating.'**
  String get tipFire2;

  /// No description provided for @tipFire3.
  ///
  /// In en, this message translates to:
  /// **'Stay low to the ground to avoid smoke inhalation.'**
  String get tipFire3;

  /// No description provided for @tipFire4.
  ///
  /// In en, this message translates to:
  /// **'Close doors behind you as you leave to slow the fire\'s spread.'**
  String get tipFire4;

  /// No description provided for @tipFire5.
  ///
  /// In en, this message translates to:
  /// **'If clothing catches fire: stop, drop, and roll.'**
  String get tipFire5;

  /// No description provided for @tipPolice1.
  ///
  /// In en, this message translates to:
  /// **'Move to a safe location away from the threat if you can.'**
  String get tipPolice1;

  /// No description provided for @tipPolice2.
  ///
  /// In en, this message translates to:
  /// **'Do not confront a suspect directly.'**
  String get tipPolice2;

  /// No description provided for @tipPolice3.
  ///
  /// In en, this message translates to:
  /// **'Note identifying details — appearance, vehicle, direction they went.'**
  String get tipPolice3;

  /// No description provided for @tipPolice4.
  ///
  /// In en, this message translates to:
  /// **'Keep bystanders away from the area.'**
  String get tipPolice4;

  /// No description provided for @tipPolice5.
  ///
  /// In en, this message translates to:
  /// **'Stay reachable in case a responder needs more information.'**
  String get tipPolice5;

  /// No description provided for @whileYouWaitTitle.
  ///
  /// In en, this message translates to:
  /// **'While You Wait — {incident}'**
  String whileYouWaitTitle(String incident);

  /// No description provided for @guidanceSheetIntro.
  ///
  /// In en, this message translates to:
  /// **'Responders are on the way. These general steps may help in the meantime.'**
  String get guidanceSheetIntro;

  /// No description provided for @guidanceSheetDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This is general guidance only and does not replace instructions from responders.'**
  String get guidanceSheetDisclaimer;

  /// No description provided for @verificationMustVerify.
  ///
  /// In en, this message translates to:
  /// **'Your account must be verified before you can send reports.'**
  String get verificationMustVerify;

  /// No description provided for @verificationNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Account not verified'**
  String get verificationNotVerified;

  /// No description provided for @verificationPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification pending'**
  String get verificationPendingTitle;

  /// No description provided for @verificationRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'Your account couldn\'t be verified, so reporting is unavailable. You can still call emergency services.'**
  String get verificationRejectedBody;

  /// No description provided for @verificationPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Reporting unlocks once an administrator verifies your account. You can still call emergency services in the meantime.'**
  String get verificationPendingBody;

  /// No description provided for @verificationBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Realtime reporting unlocks once your account is verified. You can still call emergency services.'**
  String get verificationBannerBody;

  /// No description provided for @verificationSubmittedAgo.
  ///
  /// In en, this message translates to:
  /// **'Submitted {timeAgo}.'**
  String verificationSubmittedAgo(String timeAgo);

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String timeMinutesAgo(int count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hr ago'**
  String timeHoursAgo(int count);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String timeDaysAgo(int count);

  /// No description provided for @authGoogleFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get authGoogleFailed;

  /// No description provided for @authNoUser.
  ///
  /// In en, this message translates to:
  /// **'No user is currently signed in.'**
  String get authNoUser;

  /// No description provided for @authGoogleNoPassword.
  ///
  /// In en, this message translates to:
  /// **'This account signs in with Google and has no password.'**
  String get authGoogleNoPassword;

  /// No description provided for @authEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password.'**
  String get authEnterPassword;

  /// No description provided for @authInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please check the format of your email address'**
  String get authInvalidEmail;

  /// No description provided for @authWrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get authWrongCredentials;

  /// No description provided for @authTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get authTooManyAttempts;

  /// No description provided for @authNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get authNoInternet;

  /// No description provided for @authInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code. Please try again.'**
  String get authInvalidCode;

  /// No description provided for @authInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number.'**
  String get authInvalidPhone;

  /// No description provided for @authPhoneInUse.
  ///
  /// In en, this message translates to:
  /// **'This phone number is already linked to another account.'**
  String get authPhoneInUse;

  /// No description provided for @authSmsQuota.
  ///
  /// In en, this message translates to:
  /// **'SMS quota exceeded. Please try again later.'**
  String get authSmsQuota;

  /// No description provided for @authPhoneAlreadyVerified.
  ///
  /// In en, this message translates to:
  /// **'This account already has a verified phone number.'**
  String get authPhoneAlreadyVerified;

  /// No description provided for @authEmailExists.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email. Log in with your email and password instead.'**
  String get authEmailExists;

  /// No description provided for @authWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get authWeakPassword;

  /// No description provided for @authRequiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'Please log in again to continue.'**
  String get authRequiresRecentLogin;

  /// No description provided for @authWrongGoogleAccount.
  ///
  /// In en, this message translates to:
  /// **'Please choose the same Google account you signed up with.'**
  String get authWrongGoogleAccount;

  /// No description provided for @notifChannelName.
  ///
  /// In en, this message translates to:
  /// **'Emergency updates'**
  String get notifChannelName;

  /// No description provided for @notifChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Report status and case assignment alerts'**
  String get notifChannelDescription;

  /// No description provided for @locationShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Sharing your live location'**
  String get locationShareTitle;

  /// No description provided for @locationShareBody.
  ///
  /// In en, this message translates to:
  /// **'Dispatch and the reporter can see where you are while this case is active.'**
  String get locationShareBody;

  /// No description provided for @quickReportLabel.
  ///
  /// In en, this message translates to:
  /// **'Quick Report'**
  String get quickReportLabel;

  /// No description provided for @quickReportNote.
  ///
  /// In en, this message translates to:
  /// **'This report was submitted through the quick-reporting module.'**
  String get quickReportNote;

  /// No description provided for @smsReportLabel.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get smsReportLabel;

  /// No description provided for @smsReportNote.
  ///
  /// In en, this message translates to:
  /// **'This report was submitted through the SMS module.'**
  String get smsReportNote;

  /// No description provided for @refreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Showing saved data.'**
  String get refreshFailed;

  /// No description provided for @statusTimeline.
  ///
  /// In en, this message translates to:
  /// **'Status Timeline'**
  String get statusTimeline;

  /// No description provided for @etaRecorded.
  ///
  /// In en, this message translates to:
  /// **'ETA at dispatch: {eta} ({distance})'**
  String etaRecorded(String eta, String distance);

  /// No description provided for @actualTravelTime.
  ///
  /// In en, this message translates to:
  /// **'Actual travel time: {duration}'**
  String actualTravelTime(String duration);

  /// No description provided for @guardianName.
  ///
  /// In en, this message translates to:
  /// **'Guardian Name'**
  String get guardianName;

  /// No description provided for @guardianRelationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship to guardian'**
  String get guardianRelationship;

  /// No description provided for @guardianEmail.
  ///
  /// In en, this message translates to:
  /// **'Guardian Email'**
  String get guardianEmail;

  /// No description provided for @relationshipMother.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get relationshipMother;

  /// No description provided for @relationshipFather.
  ///
  /// In en, this message translates to:
  /// **'Father'**
  String get relationshipFather;

  /// No description provided for @relationshipGrandparent.
  ///
  /// In en, this message translates to:
  /// **'Grandparent'**
  String get relationshipGrandparent;

  /// No description provided for @relationshipLegalGuardian.
  ///
  /// In en, this message translates to:
  /// **'Legal guardian'**
  String get relationshipLegalGuardian;

  /// No description provided for @relationshipOtherRelative.
  ///
  /// In en, this message translates to:
  /// **'Other relative'**
  String get relationshipOtherRelative;

  /// No description provided for @consentBannerPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for your guardian\'s approval. We sent a request to {email}.'**
  String consentBannerPending(String email);

  /// No description provided for @consentBannerRevoked.
  ///
  /// In en, this message translates to:
  /// **'Your guardian withdrew consent. Some features that store personal data are limited.'**
  String get consentBannerRevoked;

  /// No description provided for @consentResend.
  ///
  /// In en, this message translates to:
  /// **'Resend request'**
  String get consentResend;

  /// No description provided for @consentResendSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent to your guardian.'**
  String get consentResendSent;

  /// No description provided for @consentResendWait.
  ///
  /// In en, this message translates to:
  /// **'You can resend in {minutes} min.'**
  String consentResendWait(int minutes);

  /// No description provided for @consentResendTooSoon.
  ///
  /// In en, this message translates to:
  /// **'Please wait a bit before resending.'**
  String get consentResendTooSoon;

  /// No description provided for @consentResendLimit.
  ///
  /// In en, this message translates to:
  /// **'Resend limit reached. Please contact support.'**
  String get consentResendLimit;

  /// No description provided for @reportTimeoutError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm your report was sent. It may still go through once your connection recovers, so check your Reports list or try again.'**
  String get reportTimeoutError;

  /// No description provided for @medicalInfoNeedsConsent.
  ///
  /// In en, this message translates to:
  /// **'Your guardian needs to approve medical information first.'**
  String get medicalInfoNeedsConsent;

  /// No description provided for @responderNotes.
  ///
  /// In en, this message translates to:
  /// **'Responder Notes'**
  String get responderNotes;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get addNote;

  /// No description provided for @noNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes yet.'**
  String get noNotes;

  /// No description provided for @noteSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the note. Check your connection and try again.'**
  String get noteSaveError;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get edited;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get editNote;

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete note'**
  String get deleteNote;

  /// No description provided for @deleteNoteConfirm.
  ///
  /// In en, this message translates to:
  /// **'This note will be permanently removed from the case record.'**
  String get deleteNoteConfirm;

  /// No description provided for @noteDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the note. Check your connection and try again.'**
  String get noteDeleteError;

  /// No description provided for @deleteImage.
  ///
  /// In en, this message translates to:
  /// **'Delete image'**
  String get deleteImage;

  /// No description provided for @deleteImageConfirm.
  ///
  /// In en, this message translates to:
  /// **'This image will be removed from the case for everyone who can see it.'**
  String get deleteImageConfirm;

  /// No description provided for @imageDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the image. Check your connection and try again.'**
  String get imageDeleteError;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fil'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fil':
      return AppLocalizationsFil();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
