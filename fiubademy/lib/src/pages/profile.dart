import 'package:flutter/material.dart';

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
                title: Text('Santiago Czop'),
              ),
              ListTile(
                title: Text('sczop@fi.uba.ar'),
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
              ListTile(title: Text('Standard')),
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
