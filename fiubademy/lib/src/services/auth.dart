import 'package:flutter/foundation.dart';

class Auth extends ChangeNotifier {
  String? userID;
  String? userToken;

  String? getToken() {
    return userToken;
  }

  String? getID() {
    return userID;
  }

  void setAuth(String id, String token) {
    bool changed = false;
    if (token != userToken) {
      changed = true;
      userToken = token;
    }
    if (id != userID) {
      changed = true;
      userID = id;
    }
    if (changed) {
      notifyListeners();
    }
  }

  void deleteAuth() {
    userID = null;
    userToken = null;
    notifyListeners();
  }
}
