import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Auth extends ChangeNotifier {
  String? userToken;

  Auth._init();

  static Future<Auth> init() async {
    final storage = FlutterSecureStorage();
    String? savedToken = await storage.read(key: 'userToken');
    var auth = Auth._init();
    auth.userToken = savedToken;
    return auth;
  }

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
