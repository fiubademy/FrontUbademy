import 'package:fiubademy/src/models/course.dart';
import 'package:fiubademy/src/models/question.dart';
import 'package:fiubademy/src/pages/create_exam.dart';
import 'package:fiubademy/src/services/auth.dart';
import 'package:fiubademy/src/services/server.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

class Exam {
  String _examID;
  String _title;
  bool _inEdition;
  List<Question> _questions;

  Exam.fromMap(Map<String, dynamic> examData)
      : _examID = examData['ExamID'],
        _title = examData['ExamTitle'],
        _inEdition = examData['Status'] == 'EDITION',
        _questions = List.generate(examData['Questions'].length, (index) {
          return Question.fromMap(examData['Questions'][index]);
        });

  String get examID => _examID;
  String get title => _title;
  bool get inEdition => _inEdition;
}

class ExamListPage extends StatelessWidget {
  final Course course;

  const ExamListPage({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exams')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ExamCreationPage(course: course)));
        },
        label: const Text('CREATE'),
      ),
      body: SafeArea(
        child: ExamList(course: course),
      ),
    );
  }
}

class ExamList extends StatefulWidget {
  final Course course;

  const ExamList({Key? key, required this.course}) : super(key: key);

  @override
  _ExamListState createState() => _ExamListState();
}

class _ExamListState extends State<ExamList> {
  final PagingController<int, Exam> _pagingController =
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

  Future<List<Exam>> onLoad(index) async {
    Auth auth = Provider.of<Auth>(context, listen: false);
    int page = (index ~/ 5) + 1;
    final result = await Server.getExams(
      auth,
      widget.course.courseID,
    );
    if (result['error'] != null) {
      throw Exception(result['error']);
    }

    List<Map<String, dynamic>> examsData =
        List<Map<String, dynamic>>.from(result['content']);
    for (var examData in examsData) {
      final questionData = await Server.getExamQuestions(
          auth, widget.course.courseID, examData['ExamID']);
      if (questionData['error'] != null) {
        throw Exception(result['error']);
      }

      examData['Questions'] = questionData['content'];
    }

    List<Exam> exams = List.generate(
        examsData.length, (index) => Exam.fromMap(examsData[index]));
    return Future<List<Exam>>.value(exams);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: PagedListView<int, Exam>(
        padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Exam>(
          itemBuilder: (context, item, index) => ExamCard(
            exam: item,
            course: widget.course,
            onDelete: () => _pagingController.refresh(),
          ),
        ),
      ),
    );
  }
}

class ExamCard extends StatelessWidget {
  final Exam exam;
  final Course course;
  final VoidCallback? onDelete;

  const ExamCard({
    Key? key,
    required this.exam,
    required this.course,
    this.onDelete,
  }) : super(key: key);

  void _deleteExam(context) async {
    Auth auth = Provider.of<Auth>(context, listen: false);
    String? result =
        await Server.deleteExam(auth, course.courseID, exam.examID);
    if (result != null) {
      final snackBar = SnackBar(content: Text(result));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      onDelete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {},
        child: Column(
          children: [
            ListTile(
              title: Text(exam.title),
              trailing: course.role == CourseRole.owner
                  ? Wrap(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExamCreationPage(
                                    course: course,
                                    examID: exam.examID,
                                    examTitle: exam.title,
                                    questions: exam._questions),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_rounded),
                        ),
                        IconButton(
                          onPressed: () {
                            showDialog<String>(
                              context: context,
                              builder: (context) => AlertDialog(
                                  title: const Text('Delete Exam'),
                                  content: Text(
                                      'Are you sure you want to delete exam \'${exam.title}?\''),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('CANCEL'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _deleteExam(context);
                                        Navigator.pop(context);
                                      },
                                      child: const Text('DELETE'),
                                    ),
                                  ]),
                            );
                          },
                          icon: const Icon(Icons.delete_forever_rounded),
                        )
                      ],
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
