import 'dart:convert';

import 'package:http/http.dart' as http;

class Server {
  static const String url = "https://api-gateway-fiubademy.herokuapp.com/";

  static Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(url + "users/login"),
      headers: <String, String>{
        'Content-Type': 'application/json'
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password

      }),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }
}