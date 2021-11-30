import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fiubademy/src/services/auth.dart';
import 'package:fiubademy/src/widgets/course_rating.dart';
import 'package:fiubademy/src/widgets/course_tags.dart';
import 'package:fiubademy/src/models/course.dart';

class NextPage extends StatelessWidget {
  const NextPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CourseViewPage(courseID: "courseID")));
        },
        child: const Text('Go!'));
  }
}

class CourseViewPage extends StatelessWidget {
  final Course _course;

  CourseViewPage({Key? key, required Course course})
      : _course = course,
        super(key: key);

  /*Future<Map<String, dynamic>> loadCourse(String courseID) {
    return 
  }*/

  void _toggleFavorite() {
    return;
  }

  final Future<void> _delay = Future.delayed(const Duration(seconds: 1));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _delay, //Course.create(courseID, loadCourse(courseID)),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Ubademy'),
                ),
                body: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            default:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              return Scaffold(
                appBar: AppBar(title: Text('Ubademy'), actions: [
                  IconButton(
                      onPressed: () => _toggleFavorite(),
                      icon: const Icon(Icons.favorite_outline)),
                ]),
                body: _buildCourse(context),
              );
          }
        });
  }

  Widget _buildCourse(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(context),
              const SizedBox(height: 8.0),
              _buildSubtitle(context),
              const SizedBox(height: 4.0),
              const Divider(),
              const SizedBox(height: 8.0),
              ..._buildDescription(context),
              const SizedBox(height: 8.0),
              const Divider(),
              const SizedBox(height: 8.0),
              ..._buildDetails(context),
              const SizedBox(height: 8.0),
              const Divider(),
              const SizedBox(height: 8.0),
              ..._buildRatings(context),
              const SizedBox(height: 8.0),
              const Divider(),
              const Center(child: _CourseLeaveButton()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      _course.title,
      style: Theme.of(context).textTheme.headline5,
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.school,
          color: Theme.of(context).colorScheme.secondaryVariant,
        ),
        const SizedBox(width: 8.0),
        Text('by ${_course.ownerName}',
            style: Theme.of(context).textTheme.subtitle2),
        const Spacer(),
        Text(
          _course.minSubscriptionName,
          style: Theme.of(context).textTheme.subtitle2,
        ),
        const SizedBox(width: 8.0),
        Icon(
          Icons.monetization_on_rounded,
          color: Colors.green[700],
        ),
      ],
    );
  }

  List<Widget> _buildDescription(BuildContext context) {
    return [
      Text('About this course', style: Theme.of(context).textTheme.headline6),
      const SizedBox(
        height: 16.0,
      ),
      Text(_course.description),
    ];
  }

  List<Widget> _buildDetails(BuildContext context) {
    return [
      Text('Details', style: Theme.of(context).textTheme.headline6),
      const SizedBox(
        height: 16.0,
      ),
      IntrinsicHeight(
          child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.grey),
          const VerticalDivider(),
          const SizedBox(width: 8.0),
          Text(
              'Created ${_course.creationDay} ${_course.creationMonthName} ${_course.creationYear}',
              style: Theme.of(context).textTheme.subtitle1),
        ],
      )),
      const SizedBox(
        height: 16.0,
      ),
      IntrinsicHeight(
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.grey),
            const VerticalDivider(),
            const SizedBox(width: 8.0),
            Text('Facultad de Ingeniería, UBA',
                style: Theme.of(context).textTheme.subtitle1),
          ],
        ),
      ),
      const SizedBox(
        height: 16.0,
      ),
      IntrinsicHeight(
        child: Row(
          children: [
            const Icon(Icons.tag_rounded, color: Colors.grey),
            const VerticalDivider(),
            // Expanded is necessary otherwise throws error
            Expanded(
              child: CourseTags(),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildRatings(BuildContext context) {
    return [
      Text('Reviews and Ratings', style: Theme.of(context).textTheme.headline6),
      const SizedBox(height: 16.0),
      CourseRating(),
      const SizedBox(height: 8.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: () {
              if (true) {
                const snackBar = SnackBar(
                    content: Text(
                        'You need to finish the course to write a review'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } //else {
              //Navigator.push(context, route);
              //}
            },
            child: const Text('Write a review'),
          ),
          TextButton(onPressed: () {}, child: const Text('See all reviews'))
        ],
      ),
    ];
  }
}

class _CourseSignUpButton extends StatelessWidget {
  const _CourseSignUpButton({Key? key}) : super(key: key);

  void _signUpToCourse() {
    return;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
                title: const Text('Sign up'),
                content: const Text(
                    'Are you sure you want to sign up to Course Name?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _signUpToCourse();
                      Navigator.pop(context);
                    },
                    child: const Text('SIGN UP'),
                  ),
                ]),
          );
        },
        child: const Text('SIGN UP TO COURSE'));
  }
}

class _CourseLeaveButton extends StatelessWidget {
  const _CourseLeaveButton({Key? key}) : super(key: key);

  void _leaveCourse() {
    return;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
                title: const Text('Leave Course'),
                content:
                    const Text('Are you sure you want to leave Course Name?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () {
                      _leaveCourse();
                      Navigator.pop(context);
                    },
                    child: const Text('LEAVE'),
                  ),
                ]),
          );
        },
        style: ElevatedButton.styleFrom(primary: Colors.red[700]),
        child: const Text('LEAVE COURSE'));
  }
}
