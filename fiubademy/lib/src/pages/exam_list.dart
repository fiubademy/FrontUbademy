import 'package:ubademy/src/models/course.dart';
import 'package:ubademy/src/models/exam.dart';
import 'package:ubademy/src/pages/create_exam.dart';
import 'package:ubademy/src/pages/exam_solution.dart';
import 'package:ubademy/src/pages/exam_view.dart';
import 'package:ubademy/src/services/auth.dart';
import 'package:ubademy/src/services/server.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

class ExamListPage extends StatelessWidget {
  final Course course;

  const ExamListPage({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exams')),
      floatingActionButton: course.role == CourseRole.owner
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ExamCreationPage(course: course)));
              },
              label: const Text('CREATE'),
            )
          : null,
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
  final List<String> _examStates = ['All Exams'];
  final List<String> _sortingRules = ['By Date', 'By Name'];
  String _stateFilter = 'All Exams';
  String _sortingRule = 'By Date';

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    if (widget.course.role == CourseRole.owner) {
      _examStates.add('Published');
      _examStates.add('In Edition');
    }
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
    String? stateFilter =
        widget.course.role != CourseRole.owner ? 'PUBLISHED' : null;
    if (_stateFilter == 'Published') {
      stateFilter = 'PUBLISHED';
    }
    if (_stateFilter == 'In Edition') {
      stateFilter = 'EDITION';
    }
    final result = await Server.getExams(
      auth,
      widget.course.courseID,
      state: stateFilter,
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

    if (_sortingRule == 'By Name') {
      exams.sort((a, b) => a.title.compareTo(b.title));
    } else {
      exams.sort((a, b) => a.creationDate.compareTo(b.creationDate));
    }

    return Future<List<Exam>>.value(exams);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0.0),
          child: Row(
            mainAxisAlignment: widget.course.role == CourseRole.owner
                ? MainAxisAlignment.spaceAround
                : MainAxisAlignment.end,
            children: [
              if (widget.course.role == CourseRole.owner)
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    alignment: Alignment.center,
                    isDense: true,
                    value: _stateFilter,
                    onChanged: (String? newValue) {
                      setState(() {
                        _stateFilter = newValue ?? 'All Exams';
                      });
                      if (!mounted) return;
                      _pagingController.refresh();
                    },
                    items: _examStates.map(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Center(
                            child: Text(value),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  alignment: Alignment.center,
                  isDense: true,
                  value: _sortingRule,
                  onChanged: (String? newValue) {
                    setState(() {
                      _sortingRule = newValue ?? 'By Date';
                    });
                    if (!mounted) return;
                    _pagingController.refresh();
                  },
                  items: _sortingRules.map(
                    (String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Center(
                          child: Text(value),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
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
          ),
        ),
      ],
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
    final _scaffoldMessenger = ScaffoldMessenger.of(context);
    Auth auth = Provider.of<Auth>(context, listen: false);
    String? result =
        await Server.deleteExam(auth, course.courseID, exam.examID);
    if (result != null) {
      final snackBar = SnackBar(content: Text(result));
      _scaffoldMessenger.showSnackBar(snackBar);
    } else {
      onDelete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: course.role == CourseRole.student
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ExamSolutionPage(exam: exam, course: course),
                  ),
                );
              }
            : () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ExamView(exam: exam, course: course)));
              },
        child: ListTile(
          title: Text(exam.title),
          subtitle: Text(
              'Created ${exam.creationDay} ${exam.creationMonthName} ${exam.creationYear}'),
          trailing: course.role == CourseRole.owner
              ? Wrap(
                  children: [
                    if (exam.inEdition)
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExamCreationPage(
                                  course: course,
                                  examID: exam.examID,
                                  examTitle: exam.title,
                                  inEdition: exam.inEdition,
                                  questions: exam.questions),
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
                                  'Are you sure you want to delete exam \'${exam.title}\'?\n\nAll student answers and marks will be deleted forever'),
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
      ),
    );
  }
}
