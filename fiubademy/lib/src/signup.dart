import 'package:flutter/material.dart';
import 'server.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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
                const SignUpForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _signUpFormKey = GlobalKey<FormState>();
  bool _passwordObscured = true;
  bool _passwordConfirmationObscured = true;
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  String? _validateUsername(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }
    if (!RegExp(r"^[A-Za-z]+$").hasMatch(value.toLowerCase())) {
      return 'Please use only alphabetical characters';
    }
    return null;
  }

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

  String? _validatePasswordConfirmation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (_passwordController.text != value) {
      return 'Password confirmation must equal password';
    }
    return null;
  }

  void _signUp() async {
    if (_signUpFormKey.currentState!.validate()) {
      bool signedUp = await Server.signup(_usernameController.text,
          _emailController.text, _passwordController.text);
      if (signedUp) {
        await Server.login(_emailController.text, _passwordController.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _signUpFormKey,
      child: Column(
        children: [
          TextFormField(
            textInputAction: TextInputAction.next,
            controller: _usernameController,
            validator: (value) => _validateUsername(value),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              labelText: 'Username',
              filled: true,
            ),
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            textInputAction: TextInputAction.next,
            controller: _emailController,
            validator: (value) => _validateEmail(value),
            decoration: const InputDecoration(
              hintText: 'example@email.com',
              labelText: 'Email',
              filled: true,
            ),
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            textInputAction: TextInputAction.next,
            controller: _passwordController,
            obscureText: _passwordObscured,
            validator: (value) => _validatePassword(value),
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
          TextFormField(
            textInputAction: TextInputAction.done,
            controller: _passwordConfirmationController,
            obscureText: _passwordConfirmationObscured,
            validator: (value) => _validatePasswordConfirmation(value),
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
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('I already have an account'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _signUp(),
                child: Text('Sign up'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
