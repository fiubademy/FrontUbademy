import 'package:fiubademy/src/pages/create_course.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'package:fiubademy/src/models/course.dart';
import 'package:fiubademy/src/widgets/course_card.dart';
import 'package:fiubademy/src/widgets/course_list_view.dart';

class MyCoursesPage extends StatelessWidget {
  const MyCoursesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> courseData = {
      'name': 'Course Title Here',
      'ownerID': '1234234',
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

    Course myCourse = Course.create2('ABCDEF', courseData);

    List<Course> courses = List.filled(5, myCourse, growable: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
      ),
      body: SafeArea(
        child: CourseListView(
          onLoad: (index) {
            if (index < 7) {
              return courses;
            } else {
              return [];
            }
          },
        ),

        /*ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              if (index >= courses.length) {
                courses.addAll(List.filled(5, myCourse));
              }
              return CourseCard(course: courses[index]);
            }),*/
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
