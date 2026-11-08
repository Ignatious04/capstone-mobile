import 'package:url_launcher/url_launcher.dart';

Future<void> launchSms(String phoneNumber, String body) async {
  final uri = Uri.parse('sms:$phoneNumber?body=${Uri.encodeComponent(body)}');

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw Exception('Could not launch messaging app for $phoneNumber');
  }
}
