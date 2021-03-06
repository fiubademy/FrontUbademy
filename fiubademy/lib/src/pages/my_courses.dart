import 'package:ubademy/src/pages/create_course.dart';
import 'package:ubademy/src/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ubademy/src/models/course.dart';
import 'package:ubademy/src/widgets/course_list_view.dart';
import 'package:ubademy/src/services/server.dart';

class MyCoursesPage extends StatelessWidget {
  const MyCoursesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

            List<Map<String, dynamic>> coursesData =
                List<Map<String, dynamic>>.from(result['content']);
            Map<String, String> idsToNameMapping = {};
            for (var courseData in coursesData) {
              String ownerID = courseData['ownerId'];
              if (!idsToNameMapping.containsKey(ownerID)) {
                final userQuery = await Server.getUser(auth, ownerID);
                if (userQuery == null) {
                  throw Exception(result['Failed to fetch creator name']);
                }
                idsToNameMapping[ownerID] = userQuery['username'];
              }
              courseData['ownerName'] = idsToNameMapping[ownerID];
              courseData['role'] = CourseRole.owner;

              if (await Server.isFavourite(auth, courseData['id'])) {
                courseData['isFavourite'] = true;
              } else {
                courseData['isFavourite'] = false;
              }
            }

            List<Course> courses = List.generate(coursesData.length,
                (index) => Course.fromMap(coursesData[index]));
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
