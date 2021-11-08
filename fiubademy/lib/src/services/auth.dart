import 'package:flutter/foundation.dart';

class Auth extends ChangeNotifier {
  String? userToken;

  String? getToken() {
    return userToken;
  }

  void setToken(String token) {
    if (token != userToken) {
      userToken = token;
      notifyListeners();
    }
  }

  void deleteToken() {
    userToken = null;
    notifyListeners();
  }
}
