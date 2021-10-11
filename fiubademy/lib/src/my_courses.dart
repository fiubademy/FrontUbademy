import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class MyCoursesPage extends StatelessWidget {
  const MyCoursesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Courses'),
        ),
        body: Scrollbar(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: 1,
            itemBuilder: (context, index) => _buildCourse(context),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: const Text('CREATE'),
          icon: const Icon(Icons.add),
        ));
  }
}

Widget _buildCourse(BuildContext context) {
  return Column(children: [
    Card(
      child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('How to Flutter 101 - Ep. 1',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.headline6),
                  ),
                  IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
                ],
              ),
              const Divider(),
              const SizedBox(
                height: 8.0,
              ),
              Text(
                'El mejor curso que existe en el mundo para programar Flutter. En este capítulo aprenderás a instalar Flutter y crear un proyecto.',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ],
          )),
    ),
    Card(
      child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('How to Flutter 101 - Ep. 2 - The main.dart file',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.headline6),
                  ),
                  IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
                ],
              ),
              const Divider(),
              const SizedBox(
                height: 8.0,
              ),
              Text(
                'El mejor curso que existe en el mundo para programar Flutter. En este capítulo aprenderas sobre el archivo main.',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ],
          )),
    ),
    Card(
      child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('How to Flutter 101 - Ep. 3 - The Widget Tree Structure and ',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.headline6),
                  ),
                  IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
                ],
              ),
              const Divider(),
              const SizedBox(
                height: 8.0,
              ),
              Text(
                'El mejor curso que existe en el mundo para programar Flutter. En este capítulo aprenderas sobre los Widgets.',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ],
          )),
    ),
    Card(
      child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('How to Flutter 101 - Ep. 4 - How To Create Your Own Widgets',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.headline6),
                  ),
                  IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
                ],
              ),
              const Divider(),
              const SizedBox(
                height: 8.0,
              ),
              Text(
                'El mejor curso que existe en el mundo para programar Flutter. En este capítulo aprenderas sobre los Widgets.',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ],
          )),
    ),
    Card(
      child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('How to Flutter 101 - Ep. 2',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.headline6),
                  ),
                  IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
                ],
              ),
              const Divider(),
              const SizedBox(
                height: 8.0,
              ),
              Text(
                'El mejor curso que existe en el mundo para programar Flutter. En este capítulo aprenderas sobre los Widgets.',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ],
          )),
    ),
  ]);
}
