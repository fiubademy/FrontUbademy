import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';

import 'package:fiubademy/src/services/user.dart';
import 'package:fiubademy/src/services/auth.dart';
import 'package:fiubademy/src/services/google_auth.dart';
import 'package:fiubademy/src/services/location.dart';

import 'package:fiubademy/src/pages/profile.dart';
import 'package:fiubademy/src/pages/my_inscriptions.dart';
import 'package:fiubademy/src/pages/my_courses.dart';
import 'package:fiubademy/src/pages/my_collaborations.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: updateUserLocation(Provider.of<Auth>(context, listen: false),
            Provider.of<User>(context, listen: false)),
        builder: (context, AsyncSnapshot<void> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Scaffold(
                appBar: AppBar(title: const Text('Ubademy')),
                body: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            default:
              if (snapshot.hasError) {
                return _requestLocation(context);
              }
              return Scaffold(
                drawer: _buildDrawer(context),
                body: FloatingSearchAppBar(
                  body: _buildExpandableBody(context),
                  title: const Text('Ubademy'),
                ),
              );
          }
        });
  }

  Widget _requestLocation(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubademy'),
      ),
      body: SafeArea(
        child: Container(
          constraints: const BoxConstraints.expand(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off_outlined,
                size: 170,
                color: Theme.of(context).colorScheme.secondaryVariant,
              ),
              const SizedBox(height: 16.0),
              Text(
                'Whoops! It looks like your location isn\'t enabled.',
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              Text('Please enable Ubademy to access your location to continue',
                  style: Theme.of(context).textTheme.subtitle1,
                  textAlign: TextAlign.center),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () async {
                  setState(() {});
                },
                child: const Text('Enable Location'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildExpandableBody(BuildContext context) {
  return Container();
}

Widget _buildDrawer(BuildContext context) {
  return Drawer(
    child: Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                  accountName: Text(Provider.of<User>(context).username),
                  accountEmail: Text(Provider.of<User>(context).email)),
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text('My Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return const ProfilePage();
                    }),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.cases_rounded),
                title: const Text('My Inscriptions'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return const MyInscriptionsPage();
                    }),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text('My Courses'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return const MyCoursesPage();
                    }),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.supervisor_account),
                title: const Text('My Collaborations'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return const MyCollaborationsPage();
                    }),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Favourites'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('Messages'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        const Divider(),
        ListTile(
          onTap: () {
            Provider.of<Auth>(context, listen: false).deleteAuth();
            googleSignIn
                .isSignedIn()
                .then((value) => {if (value) googleSignIn.disconnect()});
          },
          leading: Icon(Icons.logout, color: Colors.red[700]),
          title: Text(
            'Log Out',
            style: TextStyle(
              color: Colors.red[700],
            ),
          ),
        ),
      ],
    ),
  );
}
