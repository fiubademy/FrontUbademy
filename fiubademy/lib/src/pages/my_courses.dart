import 'package:fiubademy/src/pages/create_course.dart';
import 'package:fiubademy/src/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/painting.dart';

import 'package:fiubademy/src/models/course.dart';
import 'package:fiubademy/src/widgets/course_card.dart';
import 'package:fiubademy/src/widgets/course_list_view.dart';
import 'package:fiubademy/src/services/server.dart';

class MyCoursesPage extends StatelessWidget {
  const MyCoursesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> courseData = {
      'id': 'asdf',
      'name': 'Course Title Here',
      'ownerId': '1234234',
      'ownerName': 'Owner Name Here',
      'sub_level': 1,
      'description': 'A small description of the course',
      'category': 'Music',
      'latitude': -34.6037,
      'longitude': -58.3816,
      'hashtags': [
        'Tag A',
        'Tag B',
        'Tag C',
        'Tag D',
        'Tag E',
        'Tag F',
        'Tag G'
      ],
      'time_created': '2021-11-29T15:19:57+0000',
      'blocked': false,
      'in_edition': false,
      'ratingCount': 24,
      'ratingAvg': 2.8,
    };

    Course myCourse = Course.fromMap(courseData);

    List<Course> courses = List.filled(5, myCourse, growable: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
      ),
      body: SafeArea(
        child: CourseListView(
          onLoad: (index) async {
            Auth auth = Provider.of<Auth>(context, listen: false);
            int page = (index ~/ 5) + 1;
            final result = await Server.getMyOwnedCourses(auth, page);
            if (result['error'] != null) {
              throw Exception(result['error']);
            }
            List<Course> courses = List.generate(result['content'].length,
                (index) => Course.fromMap(result['content'][index]));
            return Future<List<Course>>.value(courses);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const CreateCoursePage();
              },
            ),
          );
        },
        label: const Text('CREATE'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
