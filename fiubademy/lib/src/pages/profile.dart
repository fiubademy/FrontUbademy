import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fiubademy/src/services/user.dart';

class ProfilePage extends StatelessWidget {
  final User user;
  final bool isSelf;

  const ProfilePage({Key? key, required this.user, this.isSelf = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
        ),
        body: _ProfileBody(
          user: user,
          isSelf: isSelf,
        ));
  }
}

class _ProfileBody extends StatelessWidget {
  final User user;
  final bool isSelf;

  const _ProfileBody({Key? key, required this.user, this.isSelf = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        _ProfilePersonalDataCard(
          user: Provider.of<User>(context),
          isSelf: isSelf,
        ),
        if (isSelf) _ProfileSubscriptionCard(user: user),
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

class _ProfilePersonalDataCard extends StatelessWidget {
  final User user;
  final bool isSelf;

  const _ProfilePersonalDataCard(
      {Key? key, required this.user, this.isSelf = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
            child: Row(
              children: [
                Text('Personal Data',
                    style: Theme.of(context).textTheme.headline6),
                const Spacer(),
                if (isSelf)
                  IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              ],
            ),
          ),
          ListTile(
            title: Text(user.username),
          ),
          ListTile(
            title: Text(user.email),
          ),
        ],
      ),
    );
  }
}

class _ProfileSubscriptionCard extends StatelessWidget {
  final User user;

  const _ProfileSubscriptionCard({Key? key, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
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
          ListTile(title: Text(Provider.of<User>(context).subscriptionName)),
          ListTile(title: Text('Expiration: 31/12/2021')),
        ],
      ),
    );
  }
}
