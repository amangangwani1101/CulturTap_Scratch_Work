

import 'package:geocoding/geocoding.dart';
String liveLocation = '';
String CountryName = '';
String CityName = '';


Future<void> getAndPrintLocationNameFast(double latitude, double longitude) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      Placemark first = placemarks.first;
       CityName = "${first.administrativeArea}";
       liveLocation = "${first.country}";
       CountryName = "${first.country}";




    } else {
      // Return latitude and longitude if location not found

        liveLocation = '$latitude, $longitude';

    }
  } catch (e) {
    print("Error: $e");
    // Return latitude and longitude in case of an error fetching location

      liveLocation = '$latitude, $longitude';

  }
}
