import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import '../services/auth.dart';
import 'package:provider/provider.dart';
import 'package:fiubademy/src/pages/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      body: FloatingSearchAppBar(
        body: _buildExpandableBody(context),
        title: const Text('Ubademy'),
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
              _ProfileDrawerHeader(),
              const UserAccountsDrawerHeader(
                  accountName: Text('Santiago Czop'),
                  accountEmail: Text('sczop@fi.uba.ar')),
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text('My Profile'),
                onTap: () {
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
                leading: const Icon(Icons.school),
                title: const Text('My Courses'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.supervisor_account),
                title: const Text('My Collaborations'),
                onTap: () {
                  Navigator.pop(context);
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

class _ProfileDrawerHeader extends StatefulWidget {
  const _ProfileDrawerHeader({Key? key}) : super(key: key);

  @override
  _ProfileDrawerHeaderState createState() => _ProfileDrawerHeaderState();
}

class _ProfileDrawerHeaderState extends State<_ProfileDrawerHeader> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
