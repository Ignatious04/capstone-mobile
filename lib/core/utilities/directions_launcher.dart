import 'package:url_launcher/url_launcher.dart';

Future<void> launchDirections(double latitude, double longitude) async {
  final uri = Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': '$latitude,$longitude',
    'travelmode': 'driving',
  });

  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched) {
    throw 'Could not open directions to $latitude,$longitude';
  }
}
