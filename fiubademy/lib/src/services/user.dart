import 'package:flutter/foundation.dart';

import 'package:fiubademy/src/services/server.dart';

class User extends ChangeNotifier {
  String? _userID;
  String _username;
  String _email;
  double _latitude;
  double _longitude;
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
    _latitude = newUserData['latitude'];
    _longitude = newUserData['longitude'];
    _subscriptionLevel = newUserData['sub_level'];
    notifyListeners();
  }

  void deleteData() {
    _userID = '';
    _username = 'Failed to load username';
    _email = 'Failed to load email';
    _latitude = double.infinity;
    _longitude = double.infinity;
    _subscriptionLevel = 0;
    return;
  }
}
