import 'package:ubademy/src/pages/courseview.dart';
import 'package:flutter/material.dart';

import 'package:ubademy/src/models/course.dart';
import 'package:ubademy/src/widgets/course_menu.dart';
import 'package:ubademy/src/widgets/course_rating.dart';
import 'package:ubademy/src/widgets/course_tags.dart';

class CourseCard extends StatelessWidget {
  final Course _course;

  const CourseCard({Key? key, required course})
      : _course = course,
        super(key: key);

  Widget _buildMenu() {
    switch (_course.role) {
      case CourseRole.notStudent:
        return CourseNotStudentMenu(course: _course);
      case CourseRole.student:
        return CourseStudentMenu(course: _course);
      case CourseRole.owner:
        return CourseCreatorMenu(course: _course);
      case CourseRole.collaborator:
        return CourseCollaboratorMenu(course: _course);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CourseViewPage(course: _course)));
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
                      _buildMenu(),
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
                  Icon(
                    Icons.monetization_on,
                    color: _course.minSubscription == 0
                        ? Colors.brown
                        : (_course.minSubscription == 1
                            ? Colors.grey[400]
                            : Colors.amber),
                  ),
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
