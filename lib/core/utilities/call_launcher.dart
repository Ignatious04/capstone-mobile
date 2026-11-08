import 'package:url_launcher/url_launcher.dart';

Future<void> launchPhoneCall(String phoneNumber) async {
  final uri = Uri(scheme: 'tel', path: phoneNumber);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw Exception('Could not launch dialer for $phoneNumber');
  }
}
