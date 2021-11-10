import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:fiubademy/src/services/auth.dart';

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
        Map<String, dynamic> body = jsonDecode(response.body);
        auth.setAuth(body['userID'], body['sessionToken']);
        return null;
      case HttpStatus.unauthorized:
        return 'Invalid credentials';
      case HttpStatus.forbidden:
        return 'The account has been blocked blocked';
      default:
        return 'Failed to log in. Please try again in a few minutes';
    }
  }

  static Future<String?> signup(
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

    switch (response.statusCode) {
      case HttpStatus.created:
        return null;
      case HttpStatus.notAcceptable:
        return 'The account already exists';
      default:
        return 'Failed to sign up. Please try again in a few minutes';
    }
  }

  static Future<Map<String, dynamic>?> getUser(Auth auth, String userID) async {
    final Map<String, String> queryParams = {
      'user_id': userID,
    };
    final response = await http.get(
      Uri.https(url, "/users/ID/$userID"),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        return jsonDecode(response.body);
      default:
        return null;
    }
  }
}
