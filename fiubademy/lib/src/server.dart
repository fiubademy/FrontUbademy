import 'dart:io';

import 'package:http/http.dart' as http;
import 'auth.dart';

class Server {
  static const String url = "api-gateway-fiubademy.herokuapp.com";

  static bool isValidEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  static Future<String?> login(Auth auth, String email, String password) async {
    final Map<String, String> queryParams = {
      'email': email,
      'password': password,
    };
    final response = await http.post(
      Uri.https(url, "/users/login", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        auth.setToken(response.body);
        return null;
      case HttpStatus.unauthorized:
        return 'Invalid credentials';
      case HttpStatus.forbidden:
        return 'The account has been blocked blocked';
      default:
        return 'Failed to login. Please try again in a few minutes';
    }
  }

  static Future<bool> signup(
      String username, String email, String password) async {
    final Map<String, String> queryParams = {
      'username': username,
      'email': email,
      'password': password,
    };
    final response = await http.post(
      Uri.https(url, "/users/", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    print(response.statusCode);
    if (response.statusCode == HttpStatus.created) {
      print(response.body);
      return true;
    }
    return false;
  }
}
