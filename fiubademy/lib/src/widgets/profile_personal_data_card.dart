import 'package:flutter/material.dart';

import 'package:fiubademy/src/services/user.dart';

class ProfilePersonalDataCard extends StatelessWidget {
  final User user;
  final bool isSelf;

  const ProfilePersonalDataCard(
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
