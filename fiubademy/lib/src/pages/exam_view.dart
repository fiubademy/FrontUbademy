import 'package:fiubademy/src/models/course.dart';
import 'package:fiubademy/src/models/exam.dart';
import 'package:fiubademy/src/models/question.dart';
import 'package:fiubademy/src/pages/exam_correction.dart';
import 'package:fiubademy/src/pages/profile.dart';
import 'package:fiubademy/src/services/auth.dart';
import 'package:fiubademy/src/services/server.dart';
import 'package:fiubademy/src/services/user.dart';
import 'package:fiubademy/src/widgets/exam_cards.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

class ExamView extends StatelessWidget {
  final Exam exam;
  final Course course; // TODO Up to now, not used

  const ExamView({Key? key, required this.exam, required this.course})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                height: 180, child: ExamsToCorrect(exam: exam, course: course)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),
            const SizedBox(height: 8.0),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child:
                    Text('Exam', style: Theme.of(context).textTheme.headline6)),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                itemCount: exam.questions.length,
                itemBuilder: (context, index) {
                  Question question = exam.questions[index];
                  switch (question.type) {
                    case 'Development':
                      return DevelopmentQuestionCard(
                        question: question,
                        index: index,
                        enabled: false,
                      );
                    case 'True or False':
                      return TrueOrFalseQuestionCard(
                        question: question,
                        index: index,
                        enabled: false,
                      );
                    case 'Multiple Choice':
                      return MultipleChoiceQuestionCard(
                        question: question,
                        index: index,
                        initialValue: {
                          for (var item in question.options) item: false
                        },
                        enabled: false,
                      );
                    case 'Single Choice':
                      return SingleChoiceQuestionCard(
                        question: question,
                        index: index,
                        enabled: false,
                      );
                    default:
                      throw Error();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExamsToCorrect extends StatefulWidget {
  final Exam exam;
  final Course course;

  const ExamsToCorrect({Key? key, required this.exam, required this.course})
      : super(key: key);

  @override
  _ExamsToCorrectState createState() => _ExamsToCorrectState();
}

class _ExamsToCorrectState extends State<ExamsToCorrect> {
  final PagingController<int, User> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await onLoad(pageKey);

      if (!mounted) return;
      _pagingController.appendLastPage(newItems);
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

  Future<List<User>> onLoad(index) async {
    Auth auth = Provider.of<Auth>(context, listen: false);
    final result = await Server.getUncorrectedExams(
      auth,
      widget.course.courseID,
      widget.exam.examID,
    );

    if (result['error'] != null) {
      throw Exception(result['error']);
    }

    List<String> usersIDs =
        List<String>.from(result['content'].map((item) => item['student_id']));
    List<User> users = [];
    for (var userID in usersIDs) {
      final userData = await Server.getUser(auth, userID);
      if (userData == null) {
        throw Exception('Failed to fetch user data');
      }

      User newUser = User();
      newUser.updateData(userData);
      users.add(newUser);
    }

    return Future<List<User>>.value(users);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
          child: Text('Awaiting for Correction',
              style: Theme.of(context).textTheme.headline6),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => Future.sync(
              () => _pagingController.refresh(),
            ),
            child: PagedListView<int, User>(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0),
              pagingController: _pagingController,
              shrinkWrap: true,
              builderDelegate: PagedChildBuilderDelegate<User>(
                itemBuilder: (context, item, index) {
                  return Card(
                    child: ListTile(
                      title: Text(item.username),
                      subtitle: Text(item.email),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExamCorrectionPage(
                              exam: widget.exam,
                              course: widget.course,
                              student: item,
                            ),
                          ),
                        );
                      },
                      trailing: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(user: item),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person),
                      ),
                    ),
                  );
                },
                noItemsFoundIndicatorBuilder: (_) {
                  return const SizedBox(
                    height: 110,
                    child: Center(
                      child: ListTile(
                        leading: Icon(Icons.info_outline_rounded),
                        title: Text('No exams waiting for correction'),
                      ),
                    ),
                  );
                },
                noMoreItemsIndicatorBuilder: (_) {
                  return const SizedBox(
                    height: 36,
                    child: Center(
                      child: Text(
                        'No more exams waiting for correction',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
