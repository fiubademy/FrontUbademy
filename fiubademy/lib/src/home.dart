import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildDrawer(context),
      body: FloatingSearchAppBar(
        body: buildExpandableBody(),
        title: Text('Ubademy'),
      ),
    );
  }
}

Widget buildExpandableBody() {
  return Container(
    color: Colors.white,
    child: Text('Hello'),
  );
}

Widget buildDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        const UserAccountsDrawerHeader(
          accountName: Text('Santiago Czop'),
          accountEmail: Text('sczop@fi.uba.ar')
        ),
        ListTile(
          leading: Icon(Icons.account_circle),
          title: Text('My Profile'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.school),
          title: Text('My Courses'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.supervisor_account),
          title: Text('My Collaborations'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.favorite),
          title: Text('Favourites'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.message),
          title: Text('Messages'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}
