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
    bool changed = false;
    if (token != _userToken) {
      storage.write(key: 'userToken', value: token);
      changed = true;
      _userToken = token;
    }
    if (id != _userID) {
      storage.write(key: 'userID', value: id);
      changed = true;
      _userID = id;
    }
    if (changed) {
      print('Saved $userID $userToken');
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
