import 'package:firebase_messaging/firebase_messaging.dart';

class Messaging {
  static Future<String> getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    return Future.value(token);
  }
}
