import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'package:fiubademy/src/services/server.dart';

class User extends ChangeNotifier {
  String? _userID;
  String _username;
  String _email;
  double? _latitude;
  double? _longitude;
  int _subscriptionLevel;

  User()
      : _username = "Not Logged in",
        _email = 'example@mail.com',
        _latitude = 0.0,
        _longitude = 0.0,
        _subscriptionLevel = 0;

  String? get userID => _userID;
  String get username => _username;
  String get email => _email;
  int get subscriptionLevel => _subscriptionLevel;
  String get subscriptionName {
    switch (_subscriptionLevel) {
      case 0:
        return 'No subscription';
      case 1:
        return 'Standard Subscription';
      case 2:
        return 'Premium Subscription';
      default:
        return 'No subscription';
    }
  }

  void updateData(Map<String, dynamic> newUserData) {
    _userID = newUserData['user_id'];
    _username = newUserData['username'];
    _email = newUserData['email'];
    _updateLocation();
    _latitude = newUserData['latitude'];
    _longitude = newUserData['longitude'];
    _subscriptionLevel = newUserData['sub_level'];
    notifyListeners();
  }

  void _updateLocation() async {
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
    Position pos = await Geolocator.getCurrentPosition();
    _latitude = pos.latitude;
    print(_latitude);
    _longitude = pos.longitude;
    print(_longitude);
  }

  void deleteData() {
    _userID = '';
    _username = 'Failed to load username';
    _email = 'Failed to load email';
    _latitude = double.infinity;
    _longitude = double.infinity;
    _subscriptionLevel = 0;
    notifyListeners();
  }
}
