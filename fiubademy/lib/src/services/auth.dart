import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Auth extends ChangeNotifier {
  String? _userID;
  String? _userToken;

  Auth() {
    const storage = FlutterSecureStorage();
    bool retrievedSaved = false;
    storage.read(key: 'userToken').then((value) {
      _userToken = value;
      if (value != null) notifyListeners();
    });
    storage.read(key: 'userID').then((value) {
      _userID = value;
      if (value != null) notifyListeners();
    });
  }

  String? get userToken => _userToken;
  String? get userID => _userID;

  void setAuth(String id, String token) {
    const storage = FlutterSecureStorage();
    if (token != _userToken || id != _userID) {
      storage.write(key: 'userToken', value: token);
      storage.write(key: 'userID', value: id);
      _userToken = token;
      _userID = id;
      notifyListeners();
    }
  }

  void deleteAuth() {
    const storage = FlutterSecureStorage();
    storage.delete(key: 'userToken');
    storage.delete(key: 'userID');
    _userID = null;
    _userToken = null;
    notifyListeners();
  }
}
