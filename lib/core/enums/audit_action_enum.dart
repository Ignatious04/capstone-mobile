enum AuditAction {
  login('auth.login'),
  logout('auth.logout'),
  passwordChanged('auth.password_changed'),
  passwordChangeFailed('auth.password_change_failed'),
  phoneLinked('auth.phone_linked'),
  reactivationOtpVerified('auth.reactivation_otp_verified'),
  reactivationOtpFailed('auth.reactivation_otp_failed'),
  emergencyCallInitiated('emergency.call_initiated'),
  smsFallbackLaunched('emergency.sms_fallback_launched'),
  reportSubmitFailed('report.submit_failed'),
  directionsRequested('emergency.directions_requested'),
  ;

  const AuditAction(this.code);
  final String code;
}
