import 'package:fiubademy/src/signup.dart';

import 'auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'server.dart';
import 'package:provider/provider.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({Key? key}) : super(key: key);

  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  bool _passwordObscured = true;
  bool _buttonEnabled = false;
  final _loginFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty || !Server.isValidEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    return null;
  }

  void _login() async {
    if (_loginFormKey.currentState!.validate()) {
      String? tok =
          await Server.login(_emailController.text, _passwordController.text);
      Provider.of<Auth>(context, listen: false)
          .setToken("8575a03c-a6ab-44e9-912a-c77a85c71377");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Image(image: AssetImage('images/ubademy.png')),
              const SizedBox(height: 16.0),
              Form(
                key: _loginFormKey,
                onChanged: () => setState(() {
                  _buttonEnabled = _loginFormKey.currentState!.validate();
                }),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      validator: _validateEmail,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'example@email.com',
                        labelText: 'Email',
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _passwordController,
                      validator: _validatePassword,
                      obscureText: _passwordObscured,
                      decoration: InputDecoration(
                          labelText: 'Password',
                          filled: true,
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _passwordObscured = !_passwordObscured;
                                });
                              },
                              icon: Icon(_passwordObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility))),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _buttonEnabled ? _login : null,
                      child: const Text('Sign in'),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpPage()),
                      );
                    },
                    child: const Text('Sign up'),
                  )
                ],
              ),
              const Divider(),
              SizedBox(
                width: double.infinity,
                child: SignInButton(
                  Buttons.Google,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
