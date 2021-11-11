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
  double? get latitude => _latitude;
  double? get longitude => _longitude;
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

  void updateData(Map<String, dynamic> newUserData) async {
    _userID = newUserData['user_id'];
    _username = newUserData['username'];
    _email = newUserData['email'];
    _latitude = newUserData['latitude'];
    _longitude = newUserData['longitude'];
    _subscriptionLevel = newUserData['sub_level'];
    notifyListeners();
  }

  void deleteData() {
    _userID = null;
    _username = 'Failed to load username';
    _email = 'Failed to load email';
    _latitude = null;
    _longitude = null;
    _subscriptionLevel = 0;
    notifyListeners();
  }
}
