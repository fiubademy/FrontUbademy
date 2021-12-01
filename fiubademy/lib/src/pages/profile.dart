import 'package:fiubademy/src/pages/my_collaborations.dart';
import 'package:fiubademy/src/pages/my_courses.dart';
import 'package:fiubademy/src/pages/my_inscriptions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fiubademy/src/services/user.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
        ),
        body: _ProfileBody());
  }
}

class _ProfileBody extends StatefulWidget {
  const _ProfileBody({Key? key}) : super(key: key);

  @override
  _ProfileBodyState createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        Card(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                child: Row(
                  children: [
                    Text('Personal Data',
                        style: Theme.of(context).textTheme.headline6),
                    Spacer(),
                    IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
                  ],
                ),
              ),
              ListTile(
                title: Text(Provider.of<User>(context).username),
              ),
              ListTile(
                title: Text(Provider.of<User>(context).email),
              ),
            ],
          ),
        ),
        Card(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Personal Data',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
              ),
              ListTile(
                  title: Text(Provider.of<User>(context).subscriptionName)),
              ListTile(title: Text('Expiration: 31/12/2021')),
            ],
          ),
        ),
        Card(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Courses',
                      style: Theme.of(context).textTheme.headline6,
                    )),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyInscriptionsPage()));
                },
                title: const Text(
                  'My Inscriptions',
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyCoursesPage()));
                },
                title: const Text(
                  'My Courses',
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyCollaborationsPage()));
                },
                title: const Text(
                  'My Collaborations',
                ),
              ),
              ListTile(
                onTap: () {},
                title: const Text(
                  'My Favourites',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
