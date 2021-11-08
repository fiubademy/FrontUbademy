import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class Server {
  static const String url = "api-gateway-fiubademy.herokuapp.com";

  static bool isValidEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  static Future<String?> login(String email, String password) async {
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

    print(response.statusCode);
    if (response.statusCode == HttpStatus.ok) {
      return response.body;
    } else {
      return null;
    }
  }
}
