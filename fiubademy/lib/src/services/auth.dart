import 'package:flutter/foundation.dart';

class Auth extends ChangeNotifier {
  String? _userID;
  String? _userToken;

  String? get userToken {
    return _userToken;
  }

  String? get userID {
    return _userID;
  }

  void setAuth(String id, String token) {
    bool changed = false;
    if (token != userToken) {
      changed = true;
      _userToken = token;
    }
    if (id != userID) {
      changed = true;
      _userID = id;
    }
    if (changed) {
      notifyListeners();
    }
  }

  void deleteAuth() {
    _userID = null;
    _userToken = null;
    notifyListeners();
  }
}
