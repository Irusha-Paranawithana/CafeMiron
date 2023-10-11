import 'package:url_launcher/url_launcher.dart';

// ignore: non_constant_identifier_names
class MapUtils {
  static Future<void> openMap(double longitude, double latitude) async {
    String googleMapUrl =
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";

    if (await canLaunch(googleMapUrl)) {
      await launch(googleMapUrl);
    } else {
      throw "Could not open the map";
    }
  }
}
