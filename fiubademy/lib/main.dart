import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:fiubademy/src/pages/login.dart';
import 'package:fiubademy/src/pages/home.dart';
import 'package:fiubademy/src/services/auth.dart';
import 'package:fiubademy/src/services/user.dart';
import 'package:fiubademy/src/services/server.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FiubademyApp());
}

class FiubademyApp extends StatelessWidget {
  const FiubademyApp({Key? key}) : super(key: key);

  // Only called when auth changes
  void _updateUser(Auth auth, User user) async {
    if (auth.userID == null) {
      user.deleteData();
      return;
    }

    Map<String, dynamic>? userData = await Server.getUser(auth, auth.userID!);
    if (userData == null) {
      return;
    }
    user.updateData(userData);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, User>(
            create: (context) => User(),
            update: (context, auth, user) {
              if (user == null) throw ArgumentError.notNull('user');
              if (auth.userID != user.userID) {
                _updateUser(auth, user);
              }
              return user;
            },
          ),
        ],
        builder: (context, child) {
          return MaterialApp(
            title: 'Ubademy',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: Consumer<Auth>(
              builder: (context, auth, child) {
                bool isLoggedIn = auth.userToken != null;
                if (!isLoggedIn) {
                  Future.delayed(const Duration(seconds: 1), () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  });
                }
                return isLoggedIn ? const HomePage() : const LogInPage();
              },
            ),
          );
        });
  }
}
