import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Auth extends ChangeNotifier {
  String? userToken;

  Auth() {
    const storage = FlutterSecureStorage();
    storage.read(key: 'userToken').then((value) {
      userToken = value;
      if (value != null) notifyListeners();
    });
  }

  String? getToken() {
    return userToken;
  }

  void setToken(String token) {
    if (token != userToken) {
      const storage = FlutterSecureStorage();
      storage.write(key: 'userToken', value: token);
      userToken = token;
      notifyListeners();
    }
  }

  void deleteToken() {
    const storage = FlutterSecureStorage();
    storage.delete(key: 'userToken');
    userToken = null;
    notifyListeners();
  }
}
