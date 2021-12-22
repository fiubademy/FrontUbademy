import 'package:fiubademy/src/pages/chat.dart';
import 'package:fiubademy/src/pages/edit_profile.dart';
import 'package:fiubademy/src/pages/message_list.dart';
import 'package:fiubademy/src/pages/my_collaborations.dart';
import 'package:fiubademy/src/pages/my_courses.dart';
import 'package:fiubademy/src/pages/my_favourites.dart';
import 'package:fiubademy/src/pages/my_inscriptions.dart';
import 'package:fiubademy/src/pages/payment.dart';
import 'package:fiubademy/src/widgets/icon_avatar.dart';
import 'package:flutter/material.dart';
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
          title: isSelf
              ? const Text('My Profile')
              : Text('${user.username}\'s Profile'),
          actions: [
            Container(
              alignment: Alignment.centerLeft,
              height: 56,
              width: 64,
              child: IconAvatar(avatarID: user.avatarID, height: 48, width: 48),
            ),
          ]),
      floatingActionButton: isSelf
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MessageListPage(),
                  ),
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(user: user),
                  ),
                );
              },
              child: Icon(Icons.message_rounded),
            ),
      body: _ProfileBody(
        user: user,
        isSelf: isSelf,
      ),
    );
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
          user: user,
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
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const EditProfilePage()));
                      },
                      icon: const Icon(Icons.edit)),
              ],
            ),
          ),
          ListTile(
            title: Text(user.username),
          ),
          ListTile(
            title: Text(user.email),
          ),
          user.latitude != null
              ? FutureBuilder(
                  future:
                      placemarkFromCoordinates(user.latitude!, user.longitude!),
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
                )
              : const ListTile(title: Text('Failed to fetch location')),
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
            padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subscription',
                  style: Theme.of(context).textTheme.headline6,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.payment_rounded),
                ),
              ],
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentPage(),
                ),
              );
            },
            title: user.subscriptionLevel == 0
                ? const Text('No subscription active')
                : Text(user.subscriptionName),
            subtitle: user.subscriptionLevel == 0
                ? null
                : Text(
                    'Expires on ${user.expirationDay} ${user.expirationMonthName} ${user.expirationYear}'),
          ),
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
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MyFavouritesPage()));
            },
            title: const Text(
              'My Favourites',
            ),
          ),
        ],
      ),
    );
  }
}
