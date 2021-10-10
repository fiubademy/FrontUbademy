import 'package:flutter/material.dart';

import 'src/login.dart';
import 'src/signup.dart';

void main() {
  runApp(const FiubademyApp());
}

class FiubademyApp extends StatelessWidget {
  const FiubademyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SignUpPage(),
    );
  }
}