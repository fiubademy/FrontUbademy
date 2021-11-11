import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import 'package:fiubademy/src/pages/login.dart';
import 'package:fiubademy/src/pages/home.dart';
import 'package:fiubademy/src/services/auth.dart';
import 'package:fiubademy/src/services/user.dart';
import 'package:fiubademy/src/services/server.dart';
import 'package:fiubademy/src/services/location.dart';
import 'package:fiubademy/src/pages/location_request.dart';

void main() {
  runApp(const FiubademyApp());
}

class FiubademyApp extends StatelessWidget {
  const FiubademyApp({Key? key}) : super(key: key);

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

  void _updateUserLocation(Auth auth) async {
    if (auth.userID == null) {
      return;
    }

    if (await Geolocator.isLocationServiceEnabled()) {
      Position pos = await getLocation();
      Server.updatePosition(auth, pos.latitude, pos.longitude);
    }
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
              print('Updating user');
              print(auth.userID);
              if (auth.userID != user.userID) {
                print('Updating pos');
                _updateUserLocation(auth);
                print('Updating user');
                _updateUser(auth, user);
                print('Updated user');
              }
              return user;
            },
          ),
        ],
        builder: (context, child) {
          return MaterialApp(
<<<<<<< HEAD
              title: 'Ubademy',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: _switchHome(context));
=======
            title: 'Ubademy',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: Provider.of<Auth>(context).userToken == null
                ? const LogInPage()
                : const HomePage(),
            // Idea: use anonymous function. if null, also Navigator pop all.
          );
>>>>>>> development
        });
  }

  Widget _switchHome(context) {
    return Consumer<User>(builder: (context, user, child) {
      // TODO if either of the next is null, pop all navigator
      if (user.userID == null) {
        return const LogInPage();
      }

      Geolocator.isLocationServiceEnabled().then((enabled) {
        if (!enabled) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const LocationRequestPage()));
        }
      });

      return const HomePage();
    });
  }
}
