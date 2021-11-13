import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fiubademy/src/widgets/profile_personal_data_card.dart';
import 'package:fiubademy/src/services/user.dart';

class ProfilePage extends StatelessWidget {
  final User user;

  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
        ),
        body: _ProfileBody(user: user));
  }
}

class _ProfileBody extends StatefulWidget {
  final User user;

  const _ProfileBody({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileBodyState createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        ProfilePersonalDataCard(user: widget.user),
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
                onTap: () {},
                title: const Text(
                  'My Courses',
                ),
              ),
              ListTile(
                onTap: () {},
                title: const Text(
                  'My Favourites',
                ),
              ),
              ListTile(
                onTap: () {},
                title: const Text(
                  'My Inscriptions',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
