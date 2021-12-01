import 'package:fiubademy/src/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fiubademy/src/models/course.dart';
import 'package:fiubademy/src/widgets/course_list_view.dart';
import 'package:fiubademy/src/services/server.dart';

class MyInscriptionsPage extends StatelessWidget {
  const MyInscriptionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Inscriptions'),
      ),
      body: SafeArea(
        child: CourseListView(
          onLoad: (index) async {
            Auth auth = Provider.of<Auth>(context, listen: false);
            int page = (index ~/ 5) + 1;
            final result = await Server.getMyEnrolledCourses(auth, page);
            if (result['error'] != null) {
              throw Exception(result['error']);
            }
            List<Course> courses = List.generate(result['content'].length,
                (index) => Course.fromMap(result['content'][index]));
            return Future<List<Course>>.value(courses);
          },
        ),
      ),
    );
  }
}
