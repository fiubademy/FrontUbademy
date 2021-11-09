import 'package:flutter/foundation.dart';

class User extends ChangeNotifier {
  String? _userID;
  String _username;
  String _email;

  User()
      : _username = "Not Logged in",
        _email = 'example@mail.com';

  String get username => _username;
  String get email => _email;

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
