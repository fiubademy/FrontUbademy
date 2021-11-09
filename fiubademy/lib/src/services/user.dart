import 'package:flutter/foundation.dart';

class User extends ChangeNotifier {
  String? _userID;
  String _username;
  String _email;
  int _subscriptionLevel;

  User()
      : _username = "Not Logged in",
        _email = 'example@mail.com',
        _subscriptionLevel = 0;

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

  set userID(String? newUserID) {
    if (_userID != newUserID) {
      _userID = newUserID;
      updateUser();
      notifyListeners();
    }
  }

  void updateUser() {
    return;
  }
}
