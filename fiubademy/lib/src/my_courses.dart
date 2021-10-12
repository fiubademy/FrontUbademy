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
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                          'How to Flutter 101 - Ep. 3 - The Widget Tree Structure and ',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.headline6),
                    ),
                    IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
                  ],
                ),
                Divider(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Standard',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Text(
                  'Closed',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(
              'El mejor curso que existe en el mundo para programar Flutter. En este capítulo aprenderas sobre los Widgets.',
            ),
          ),
          ListTile(
            title: Text('Sillicon Valley, USA'),
            leading: Icon(Icons.location_pin),
            minLeadingWidth: 16,
          ),
          SizedBox(
            width: double.maxFinite,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.start,
                alignment: WrapAlignment.start,

                children: [
                  Chip(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    label: Text('Flutter'),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap
                  ),
                  Chip(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    label: Text('Programming'),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ]);
}
