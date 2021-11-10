import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Auth extends ChangeNotifier {
  String? _userID;
  String? _userToken;

  Auth() {
    const storage = FlutterSecureStorage();
    storage.read(key: 'userToken').then((value) {
      _userToken = value;
      if (value != null) notifyListeners();
    });
  }

  String? get userToken => _userToken;
  String? get userID => _userID;

  void setAuth(String id, String token) {
    bool changed = false;
    if (token != _userToken) {
      const storage = FlutterSecureStorage();
      storage.write(key: 'userToken', value: token);
      changed = true;
      _userToken = token;
    }
    if (id != _userID) {
      changed = true;
      _userID = id;
    }
    if (changed) {
      notifyListeners();
    }
  }

  void deleteAuth() {
    const storage = FlutterSecureStorage();
    storage.delete(key: 'userToken');
    _userID = null;
    _userToken = null;
    notifyListeners();
  }
}
