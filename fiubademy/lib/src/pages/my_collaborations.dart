import 'package:fiubademy/src/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fiubademy/src/models/course.dart';
import 'package:fiubademy/src/widgets/course_list_view.dart';
import 'package:fiubademy/src/services/server.dart';

class MyCollaborationsPage extends StatelessWidget {
  const MyCollaborationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Collaborations'),
      ),
      body: SafeArea(
        child: CourseListView(
          onLoad: (index) async {
            Auth auth = Provider.of<Auth>(context, listen: false);
            int page = (index ~/ 5) + 1;
            final result = await Server.getMyCollaborationCourses(auth, page);
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
              courseData['isEnrolled'] = false;
            }

            List<Course> courses = List.generate(coursesData.length,
                (index) => Course.fromMap(coursesData[index]));
            return Future<List<Course>>.value(courses);
          },
        ),
      ),
    );
  }
}
