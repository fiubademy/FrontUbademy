import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _passwordObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
            child: Scrollbar(
          isAlwaysShown: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Image(
                  image: AssetImage('images/ubademy.png')
                ),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'example@email.com',
                    labelText: 'Email',
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _passwordObscured = !_passwordObscured;
                        });
                      },
                      icon: Icon(
                        _passwordObscured
                        ? Icons.visibility_off
                        : Icons.visibility
                      )
                    )
                  ),
                  obscureText: _passwordObscured,
                ),
                const ElevatedButton(onPressed: null, child: Text('Sign in'))
              ],
            ),
          ),
        )),
      ),
    );
  }
}