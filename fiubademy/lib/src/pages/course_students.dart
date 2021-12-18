import 'package:fiubademy/src/pages/profile.dart';
import 'package:fiubademy/src/services/auth.dart';
import 'package:fiubademy/src/services/server.dart';
import 'package:fiubademy/src/services/user.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

class CourseStudentsPage extends StatefulWidget {
  final String _courseID;

  const CourseStudentsPage({Key? key, required String courseID})
      : _courseID = courseID,
        super(key: key);

  @override
  _CourseStudentsPageState createState() => _CourseStudentsPageState();
}

class _CourseStudentsPageState extends State<CourseStudentsPage> {
  final PagingController<int, User> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  void _fetchPage(int pageKey) async {
    try {
      Auth auth = Provider.of<Auth>(context, listen: false);
      final newItems = await Server.getCourseStudents(auth, widget._courseID);

      if (newItems['error'] != null) {
        throw Exception('Failed to load student');
      }

      List<String> studentsIDs = List<String>.from(newItems['content']);

      // Can be optimized to make all API calls at once and wait for them
      List<User> students = [];
      for (final studentID in studentsIDs) {
        final studentData = await Server.getUser(auth, studentID);
        if (studentData == null) {
          throw Exception('Failed to load student');
        }
        User user = User();
        user.updateData(studentData);
        students.add(user);
      }

      // If not mounted, using page controller throws Error.
      if (!mounted) return;

      _pagingController.appendLastPage(students);
    } on Exception catch (error) {
      String errorMessage = error.toString();
      // Show snackbar only if planned error
      if (errorMessage.startsWith('Exception: ')) {
        // Keep only part past 'Exception: '. Yes, it's ugly.
        final snackBar =
            SnackBar(content: Text(error.toString().substring(11)));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      if (!mounted) return;
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
      ),
      // TODO Review the use of Safe Area in every scaffold.
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => Future.sync(
            () => _pagingController.refresh(),
          ),
          child: PagedListView(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<User>(
              itemBuilder: (context, item, index) => Card(
                child: ListTile(
                  title: Text(item.username),
                  subtitle: Text(item.email),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(user: item),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
