import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _passwordObscured = true;
  bool _passwordConfirmationObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Image(image: AssetImage('images/ubademy.png')),
                const SizedBox(height: 16.0),
                Form(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                filled: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: TextFormField(
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Last Name',
                                filled: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
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
                        textInputAction: TextInputAction.next,
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
                        obscureText: _passwordObscured,
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                            labelText: 'Password Confirmation',
                            filled: true,
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _passwordConfirmationObscured =
                                        !_passwordConfirmationObscured;
                                  });
                                },
                                icon: Icon(_passwordConfirmationObscured
                                    ? Icons.visibility_off
                                    : Icons.visibility))),
                        obscureText: _passwordConfirmationObscured,
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: const Text('I already have an account'),
                          ),
                          const Spacer(),
                          const ElevatedButton(
                            onPressed: null,
                            child: Text('Sign up'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
