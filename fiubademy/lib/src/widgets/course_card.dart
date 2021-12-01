import 'package:fiubademy/src/pages/courseview.dart';
import 'package:flutter/material.dart';

import 'package:fiubademy/src/models/course.dart';
import 'package:fiubademy/src/widgets/course_creator_menu.dart';
import 'package:fiubademy/src/widgets/course_rating.dart';
import 'package:fiubademy/src/widgets/course_tags.dart';

class CourseCard extends StatelessWidget {
  final Course _course;

  const CourseCard({Key? key, required course})
      : _course = course,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CourseViewPage(
                      course: _course, isFavorite: false, isEnrolled: false)));
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(_course.title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.headline6),
                      ),
                      const CourseCreatorMenu(),
                    ],
                  ),
                  const Divider(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
              child: Row(
                children: [
                  Text(
                    _course.category,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  const Spacer(),
                  Text(
                    _course.minSubscriptionName,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  const SizedBox(width: 8.0),
                  Icon(Icons.monetization_on, color: Colors.green[700]),
                ],
              ),
            ),
            ListTile(
              title: Text(_course.description),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: CourseRating(
                count: _course.ratingCount,
                avg: _course.ratingAvg,
              ),
            ),
            if (_course.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CourseTags(tags: _course.tags),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
