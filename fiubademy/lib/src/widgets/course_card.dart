import 'package:fiubademy/src/widgets/course_creator_menu.dart';
import 'package:fiubademy/src/widgets/course_rating.dart';
import 'package:fiubademy/src/widgets/course_tags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
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
                    CourseCreatorMenu(),
                  ],
                ),
                Divider(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            child: Row(
              children: [
                Text(
                  'Closed',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                const Spacer(),
                Text(
                  'Standard',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                const SizedBox(width: 8.0),
                Icon(Icons.monetization_on, color: Colors.green[700]),
              ],
            ),
          ),
          ListTile(
            title: Text(
              'El mejor curso que existe en el mundo para programar Flutter. En este capítulo aprenderas sobre los Widgets.',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            child: CourseRating(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
            child: CourseTags(),
          ),
        ],
      ),
    );
  }
}
