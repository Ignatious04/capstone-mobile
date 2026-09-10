import 'package:url_launcher/url_launcher.dart';

Future<void> launchSms(String phoneNumber, String body) async {
  final uri = Uri(
    scheme: 'sms',
    path: phoneNumber,
    queryParameters: {'body': body},
  );

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch messaging app for $phoneNumber';
  }
}