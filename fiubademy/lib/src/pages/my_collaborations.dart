import 'package:fiubademy/src/pages/courseview.dart';
import 'package:fiubademy/src/pages/profile.dart';
import 'package:fiubademy/src/services/auth.dart';
import 'package:fiubademy/src/services/user.dart';
import 'package:fiubademy/src/widgets/icon_avatar.dart';
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
        child: Column(
          children: [
            const InvitationsList(),
            Expanded(
              child: CourseListView(
                onLoad: (index) async {
                  Auth auth = Provider.of<Auth>(context, listen: false);
                  int page = (index ~/ 5) + 1;
                  final result =
                      await Server.getMyCollaborationCourses(auth, page);
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
                    courseData['role'] = CourseRole.collaborator;

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
          ],
        ),
      ),
    );
  }
}

class InvitationsList extends StatefulWidget {
  const InvitationsList({Key? key}) : super(key: key);

  @override
  _InvitationsListState createState() => _InvitationsListState();
}

class _InvitationsListState extends State<InvitationsList> {
  bool _isLoading = false;

  Future<Map<String, dynamic>> _getInvitations(BuildContext context) async {
    Auth auth = Provider.of<Auth>(context, listen: false);
    Map<String, dynamic>? result =
        await Server.getMyCollaborationInvitations(auth);
    if (result['error'] != null) {
      return {};
    }

    List<String> coursesIDs = result['content'];
    List<Course> courses = [];
    Map<String, User> owners = {};

    Map<String, String> idsToNameMapping = {};
    for (var courseID in coursesIDs) {
      result = await Server.getCourse(auth, courseID);
      if (result == null) {
        return {};
      }
      String ownerID = result['ownerId'];
      if (!idsToNameMapping.containsKey(ownerID)) {
        final userQuery = await Server.getUser(auth, ownerID);
        if (userQuery == null) {
          return {};
        }
        idsToNameMapping[ownerID] = userQuery['username'];
        User owner = User();
        owner.updateData(userQuery);
        owners[ownerID] = owner;
      }
      result['ownerName'] = idsToNameMapping[ownerID];
      result['role'] = CourseRole.notStudent;
      if (await Server.isFavourite(auth, courseID)) {
        result['isFavourite'] = true;
      } else {
        result['isFavourite'] = false;
      }
      courses.add(Course.fromMap(result));
    }

    return {'courses': courses, 'owners': owners};
  }

  void _acceptInvitation(String courseID) async {
    if (_isLoading) return;
    _isLoading = true;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    Auth auth = Provider.of<Auth>(context, listen: false);
    var result = await Server.acceptCollaborationInvitation(auth, courseID);

    if (result != null) {
      final snackBar = SnackBar(content: Text(result));
      scaffoldMessenger.showSnackBar(snackBar);
      _isLoading = false;
    } else {
      _isLoading = false;
      if (!mounted) return;
      setState(() {});
    }
  }

  void _rejectInvitation(String courseID) async {
    if (_isLoading) return;
    _isLoading = true;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    Auth auth = Provider.of<Auth>(context, listen: false);
    var result = await Server.rejectCollaborationInvitation(auth, courseID);

    if (result != null) {
      final snackBar = SnackBar(content: Text(result));
      scaffoldMessenger.showSnackBar(snackBar);
      _isLoading = false;
    } else {
      _isLoading = false;
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getInvitations(context),
      builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            );
          default:
            if (snapshot.hasError) {
              const snackBar = SnackBar(
                  content: Text('Failed to load invitations to collaborate'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              return const SizedBox.shrink();
            }

            if (!snapshot.hasData || snapshot.data == null) {
              const snackBar = SnackBar(
                  content: Text('Failed to load invitations to collaborate'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              return const SizedBox.shrink();
            }

            if (snapshot.data!.isEmpty || snapshot.data!['courses'].isEmpty) {
              return const SizedBox.shrink();
            }

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Invitations to Collaborate',
                        style: Theme.of(context).textTheme.headline6),
                    const SizedBox(height: 16.0),
                    Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!['courses'].length,
                        itemBuilder: (context, index) {
                          Course course = snapshot.data!['courses'][index];
                          User owner = snapshot.data!['owners'][course.ownerID];
                          return Card(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CourseViewPage(course: course),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.fromLTRB(
                                        16.0, 16.0, 16.0, 8.0),
                                    child: Text(course.title,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16.0, 0.0, 16.0, 16.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          course.category,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1,
                                        ),
                                        const Spacer(),
                                        Text(
                                          course.minSubscriptionName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1,
                                        ),
                                        const SizedBox(width: 8.0),
                                        Icon(
                                          Icons.monetization_on,
                                          color: course.minSubscription == 0
                                              ? Colors.brown
                                              : (course.minSubscription == 1
                                                  ? Colors.grey[400]
                                                  : Colors.amber),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Text('Invited by',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  ListTile(
                                      leading: IconAvatar(
                                        avatarID: owner.avatarID,
                                      ),
                                      title: Text(owner.username),
                                      subtitle: Text(owner.email),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProfilePage(
                                              user: owner,
                                            ),
                                          ),
                                        );
                                      }),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () {
                                            _rejectInvitation(course.courseID);
                                          },
                                          child: const Text('REJECT'),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () {
                                            _acceptInvitation(course.courseID);
                                          },
                                          child: const Text('ACCEPT'),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              ),
            );
        }
      },
    );
  }
}
