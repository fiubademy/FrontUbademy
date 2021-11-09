import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fiubademy/src/pages/login.dart';
import 'package:fiubademy/src/pages/home.dart';
import 'package:fiubademy/src/services/auth.dart';

void main() {
  runApp(const FiubademyApp());
}

class FiubademyApp extends StatelessWidget {
  const FiubademyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => Auth(),
        builder: (context, child) {
          return MaterialApp(
            title: 'Ubademy',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: Provider.of<Auth>(context).getToken() == null
                ? const LogInPage()
                : const HomePage(),
          );
        });
  }
}
