import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fiubademy/src/services/auth.dart';
import 'package:fiubademy/src/services/server.dart';
import 'package:fiubademy/src/services/user.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Change Username',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 16.0),
                  const ProfileChangeForm(),
                  const Divider(),
                  const SizedBox(height: 8.0),
                  Text(
                    'Change Password',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 16.0),
                  const PasswordChangeForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileChangeForm extends StatefulWidget {
  const ProfileChangeForm({Key? key}) : super(key: key);

  @override
  _ProfileChangeFormState createState() => _ProfileChangeFormState();
}

class _ProfileChangeFormState extends State<ProfileChangeForm> {
  bool _isLoading = false;
  final _editProfileFormKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  String? _validateUsername(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }
    if (!RegExp(r"^[A-Za-z]+$").hasMatch(value.toLowerCase())) {
      return 'Please use only alphabetical characters';
    }
    return null;
  }

  void _updateProfile() async {
    setState(() {
      _isLoading = true;
    });
    FocusScope.of(context).unfocus();
    if (_editProfileFormKey.currentState!.validate()) {
      Auth auth = Provider.of<Auth>(context, listen: false);
      String result =
          await Server.updateProfile(auth, _usernameController.text);
      if (result == 'Your username has been correctly changed.') {
        Provider.of<User>(context, listen: false).username =
            _usernameController.text;
      }
      final snackBar = SnackBar(content: Text(result));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _editProfileFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _usernameController,
            textInputAction: TextInputAction.none,
            validator: (value) => _validateUsername(value),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              labelText: 'Username',
              filled: true,
            ),
          ),
          const SizedBox(height: 16.0),
          Align(
            alignment: Alignment.centerRight,
            child: _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      _updateProfile();
                    },
                    child: const Text('SAVE'),
                  ),
          )
        ],
      ),
    );
  }
}

class PasswordChangeForm extends StatefulWidget {
  const PasswordChangeForm({Key? key}) : super(key: key);

  @override
  _PasswordChangeFormState createState() => _PasswordChangeFormState();
}

class _PasswordChangeFormState extends State<PasswordChangeForm> {
  bool _isLoading = false;
  bool _oldPasswordObscured = true;
  bool _passwordObscured = true;
  bool _passwordConfirmationObscured = true;
  final _updatePasswordFormKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  String? _validateOldPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must have 8 or more characters';
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
    if (value.length < 8) {
      return 'Password must have 8 or more characters';
    }
    return null;
  }

  void _changePassword() async {
    setState(() {
      _isLoading = true;
    });
    FocusScope.of(context).unfocus();
    if (_updatePasswordFormKey.currentState!.validate()) {
      Auth auth = Provider.of<Auth>(context, listen: false);
      String result = await Server.changePassword(
          auth, _oldPasswordController.text, _passwordController.text);
      if (result == 'Your password has been succesfully changed.') {
        _oldPasswordController.clear();
        _passwordController.clear();
        _passwordConfirmationController.clear();
      }
      final snackBar = SnackBar(content: Text(result));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _updatePasswordFormKey,
      child: Column(
        children: [
          TextFormField(
            textInputAction: TextInputAction.next,
            controller: _oldPasswordController,
            obscureText: _oldPasswordObscured,
            validator: (value) => _validateOldPassword(value),
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
                    : Icons.visibility),
              ),
            ),
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
                    : Icons.visibility),
              ),
            ),
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
                    : Icons.visibility),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Align(
            alignment: Alignment.centerRight,
            child: _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      _changePassword();
                    },
                    child: const Text('SAVE'),
                  ),
          ),
        ],
      ),
    );
  }
}

/*
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

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
*/