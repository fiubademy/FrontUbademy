import 'package:fiubademy/src/services/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fiubademy/src/services/auth.dart';
import 'package:fiubademy/src/services/server.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditInfoState createState() => _EditInfoState();
}

class _EditInfoState extends State<EditProfilePage> {
  final _editInfoKey = GlobalKey<FormState>();
  final _changePasswordFormKey = GlobalKey<FormState>();
  bool isLoadingInfo = false;
  bool isLoadingPassword = false;
  final _usernameController = TextEditingController();
  bool _passwordObscured = true;
  bool _passwordConfirmationObscured = true;
  bool _oldPasswordObscured = true;
  final _oldPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

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

  String? _validateUsername(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }
    if (!RegExp(r"^[A-Za-z]+$").hasMatch(value.toLowerCase())) {
      return 'Please use only alphabetical characters';
    }
    return null;
  }

  void _editInfo(BuildContext context) async {
    setState(() {
      isLoadingInfo = true;
    });
    final Auth auth = Provider.of<Auth>(context, listen: false);
    FocusScope.of(context).unfocus();
    if (_editInfoKey.currentState!.validate()) {
      String? result = await Server.editInfoUser(
        _usernameController.text, 
        auth
      );
      if (result != null) {
        final snackBar = SnackBar(content: Text(result));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
    setState(() {
      isLoadingInfo = false;
    });
  }

  void _changePassword(BuildContext context) async {
    setState(() {
      isLoadingPassword = true;
    });
    final Auth auth = Provider.of<Auth>(context, listen: false);
    FocusScope.of(context).unfocus();
    if (_changePasswordFormKey.currentState!.validate()) {
      String? result = await Server.changePassword(
        _oldPasswordController.text, 
        _passwordController.text,
        auth
      );
      if (result != null) {
        final snackBar = SnackBar(content: Text(result));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
    setState(() {
      isLoadingPassword = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body:Column(
        children:[
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Change Username',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
          Form(
            key: _editInfoKey,
            child:
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
          ),
          const SizedBox(height: 16.0),
          Align(
            alignment: Alignment.centerRight,
            child:
              isLoadingInfo
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: (){_editInfo(context);},
                    child: const Text('Change Username'),
                  ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Change Password',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
          Form(
            key: _changePasswordFormKey,
            child:
              Column(children: [
                TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: _oldPasswordController,
                  obscureText: _oldPasswordObscured,
                  validator: (value) => _validatePassword(value),
                  decoration: InputDecoration(
                      labelText: 'Old Password',
                      filled: true,
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _oldPasswordObscured = !_oldPasswordObscured;
                            });
                          },
                          icon: Icon(_oldPasswordObscured
                              ? Icons.visibility_off
                              : Icons.visibility))),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: _passwordController,
                  obscureText: _passwordObscured,
                  validator: (value) => _validatePassword(value),
                  decoration: InputDecoration(
                      labelText: 'New Password',
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
                      labelText: 'New Password Confirmation',
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
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Align(
            alignment: Alignment.centerRight,
            child:
              isLoadingPassword
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _changePassword(context),
                      child: const Text('Change Password'),
                    ),
          ),
        ]
      )
    );
  }
}