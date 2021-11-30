import 'package:fiubademy/src/services/location.dart';
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
    Map<String, dynamic> courseData = {
      'name': 'Course Title Here',
      'ownerID': '1234234',
      'ownerName': 'Owner Name Here',
      'sub_level': 1,
      'description': 'A small description of the course',
      'category': 'Business',
      'latitude': -34.6037,
      'longitude': -58.3816,
      'hashtags': ['Tag A', 'Tag B', 'Tag C'],
      'time_created': '2021-11-29T15:19:57+0000',
      'blocked': false,
      'in_edition': false,
      'ratingCount': 24,
      'ratingAvg': 2.8,
    };

    Course myCourse = Course.create2('ABCDEF', courseData);

    return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              /*
              builder: (context) => FutureBuilder(
                future: myCourse,
                builder:
                    (BuildContext context, AsyncSnapshot<Course> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Container();
                    default:
                      if (snapshot.hasError) {
                        return Container();
                      }
                      return CourseViewPage(course: snapshot.data!);
                  }
                },
              ),*/
              builder: (context) => CourseViewPage(
                  course: myCourse, isEnrolled: false, isFavorite: true),
            ),
          );
        },
        child: const Text('Go!'));
  }
}

class CourseViewPage extends StatelessWidget {
  final Course _course;
  bool _isFavorite;
  bool _isEnrolled;

  CourseViewPage(
      {Key? key,
      required Course course,
      required bool isFavorite,
      required bool isEnrolled})
      : _course = course,
        _isFavorite = isFavorite,
        _isEnrolled = isEnrolled,
        super(key: key);

  /*Future<Map<String, dynamic>> loadCourse(String courseID) {
    return 
  }*/

  void _toggleFavorite() {
    return;
  }

  final Future<void> _delay = Future.delayed(const Duration(seconds: 0));

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
                      icon: _isFavorite
                          ? const Icon(Icons.favorite, color: Colors.red)
                          : const Icon(Icons.favorite_outline)),
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
              Center(
                child: _isEnrolled
                    ? _CourseLeaveButton(courseTitle: _course.title)
                    : _CourseSignUpButton(courseTitle: _course.title),
              ),
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
            FutureBuilder(
              future: getLocationName(_course.latitude, _course.longitude),
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Text('Fetching location',
                        style: Theme.of(context).textTheme.subtitle1);
                  default:
                    if (snapshot.hasError) {
                      return Text('Failed to fetch location',
                          style: Theme.of(context).textTheme.subtitle1);
                    }
                    if (snapshot.data == null) {
                      return Text('Failed to fetch location',
                          style: Theme.of(context).textTheme.subtitle1);
                    }
                    return Text(snapshot.data!,
                        style: Theme.of(context).textTheme.subtitle1);
                }
              },
            ),
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
              child: CourseTags(tags: _course.tags),
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
      CourseRating(avg: _course.ratingAvg, count: _course.ratingCount),
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
  final String _courseTitle;

  const _CourseSignUpButton({Key? key, required String courseTitle})
      : _courseTitle = courseTitle,
        super(key: key);

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
                title: const Text('Enroll to Course'),
                content:
                    Text('Are you sure you want to enroll to $_courseTitle?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('CANCEL'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _signUpToCourse();
                      Navigator.pop(context);
                    },
                    child: const Text('ENROLL'),
                  ),
                ]),
          );
        },
        child: const Text('ENROLL TO COURSE'));
  }
}

class _CourseLeaveButton extends StatelessWidget {
  final String _courseTitle;

  const _CourseLeaveButton({Key? key, required String courseTitle})
      : _courseTitle = courseTitle,
        super(key: key);

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
                title: const Text('Unsubscribe from Course'),
                content: Text('Are you sure you want to leave $_courseTitle?'),
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
                    child: const Text('UNSUBSCRIBE'),
                  ),
                ]),
          );
        },
        style: ElevatedButton.styleFrom(primary: Colors.red[700]),
        child: const Text('UNSUBSCRIBE FROM COURSE'));
  }
}
