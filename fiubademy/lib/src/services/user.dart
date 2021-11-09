import 'package:flutter/foundation.dart';

class User extends ChangeNotifier {
  late String? _userID;

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
