import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:ubademy/src/services/auth.dart';
import 'package:ubademy/src/services/server.dart';
import 'package:ubademy/src/services/user.dart';

Future<Position> getLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

Future<void> updateUserLocation(Auth auth, User user) async {
  return Future.sync(() async {
    if (auth.userID == null) {
      return;
    }

    Position pos;
    try {
      pos = await getLocation();
    } catch (e) {
      return Future.error('Failed to get location.');
    }
    Server.updatePosition(auth, pos.latitude, pos.longitude);
    user.setPosition(pos.latitude, pos.longitude);
  });
}

Future<String?> getLocationName(double latitude, double longitude) async {
  Placemark placemark =
      (await placemarkFromCoordinates(latitude, longitude))[0];
  return '${placemark.administrativeArea}, ${placemark.country}';
}
