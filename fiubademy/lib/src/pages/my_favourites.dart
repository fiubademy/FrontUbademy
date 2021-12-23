import 'package:fiubademy/src/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fiubademy/src/models/course.dart';
import 'package:fiubademy/src/widgets/course_list_view.dart';
import 'package:fiubademy/src/services/server.dart';

class MyFavouritesPage extends StatelessWidget {
  const MyFavouritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favourites'),
      ),
      body: SafeArea(
        child: CourseListView(
          onLoad: (index) async {
            Auth auth = Provider.of<Auth>(context, listen: false);
            int page = (index ~/ 5) + 1;
            final result = await Server.getMyFavouriteCourses(auth, page);
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
              // Order is by speed and then probability
              if (ownerID == auth.userID) {
                courseData['role'] = CourseRole.owner;
              } else if (await Server.isEnrolled(auth, courseData['id'])) {
                courseData['role'] = CourseRole.student;
              } else if (await Server.isCollaborator(auth, courseData['id'])) {
                courseData['role'] = CourseRole.collaborator;
              } else {
                courseData['role'] = CourseRole.notStudent;
              }

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
    );
  }
}
