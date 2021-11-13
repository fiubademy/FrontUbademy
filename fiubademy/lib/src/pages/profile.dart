import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fiubademy/src/services/user.dart';
import 'package:geocoding/geocoding.dart';

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
      padding: const EdgeInsets.all(16.0),
      children: [
        _ProfilePersonalDataCard(
          user: Provider.of<User>(context),
          isSelf: isSelf,
        ),
        if (isSelf) _ProfileSubscriptionCard(user: user),
        if (isSelf) _ProfileCoursesCard(user: user),
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
            padding: EdgeInsets.fromLTRB(
                16.0, isSelf ? 4.0 : 16.0, 16.0, isSelf ? 4.0 : 16.0),
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
          FutureBuilder(
            future: placemarkFromCoordinates(user.latitude!, user.longitude!),
            builder: (BuildContext context,
                AsyncSnapshot<List<Placemark>> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const ListTile(title: Text('Fetching location'));
                default:
                  if (snapshot.hasError) {
                    return const ListTile(
                        title: Text('Failed to fetch location'));
                  }
                  Placemark placemark = snapshot.data![0];
                  return ListTile(
                      title: Text(
                          '${placemark.administrativeArea}, ${placemark.country}'));
              }
            },
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
                'Subscription',
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

class _ProfileCoursesCard extends StatelessWidget {
  final User user;

  const _ProfileCoursesCard({Key? key, required this.user}) : super(key: key);

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
    );
  }
}
