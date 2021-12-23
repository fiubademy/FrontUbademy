import 'package:ubademy/src/models/course.dart';
import 'package:ubademy/src/models/exam.dart';
import 'package:ubademy/src/models/question.dart';
import 'package:ubademy/src/services/auth.dart';
import 'package:ubademy/src/services/server.dart';
import 'package:ubademy/src/services/user.dart';
import 'package:ubademy/src/widgets/exam_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ExamCorrectionPage extends StatelessWidget {
  final Course course;
  final Exam exam;
  final User student;
  final Map<String, String> _questionAnswers = {};

  ExamCorrectionPage(
      {Key? key,
      required this.exam,
      required this.student,
      required this.course})
      : super(key: key);

  Future<void> _loadAnswers(context) async {
    Auth auth = Provider.of<Auth>(context, listen: false);
    for (var question in exam.questions) {
      Map<String, dynamic> result = await Server.getQuestionAnswer(
        auth,
        course.courseID,
        question.id!,
        student.userID!,
      );

      if (result['error'] != null) {
        throw Exception(result['error']);
      }

      _questionAnswers[question.id!] = result['content'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Correction')),
      body: SafeArea(
        child: Column(
          children: [
            ExamMarkForm(exam: exam, course: course, student: student),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8.0),
                  Text(
                    'Student\'s Answer',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
            FutureBuilder(
              future: _loadAnswers(context),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const SizedBox(
                      height: 300,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  default:
                    if (snapshot.hasError) {
                      return SizedBox(
                        height: 300,
                        child: Center(
                          child: Text(
                            snapshot.error.toString().substring(11),
                          ),
                        ),
                      );
                    }

                    return Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                        itemCount: exam.questions.length,
                        itemBuilder: (context, index) {
                          Question question = exam.questions[index];
                          switch (question.type) {
                            case 'Development':
                              return DevelopmentQuestionCard(
                                  question: question,
                                  index: index,
                                  enabled: false,
                                  initialValue: _questionAnswers[question.id]);
                            case 'True or False':
                              return TrueOrFalseQuestionCard(
                                question: question,
                                index: index,
                                enabled: false,
                                initialValue:
                                    _questionAnswers[question.id] == 'True',
                              );
                            case 'Multiple Choice':
                              List<String> selectedOptions =
                                  _questionAnswers[question.id]?.split(';') ??
                                      [];
                              Map<String, bool> answer = {
                                for (var opt in question.options)
                                  opt: selectedOptions.contains(opt)
                              };

                              return MultipleChoiceQuestionCard(
                                question: question,
                                index: index,
                                initialValue: answer,
                                enabled: false,
                              );
                            case 'Single Choice':
                              return SingleChoiceQuestionCard(
                                  question: question,
                                  index: index,
                                  enabled: false,
                                  initialValue: _questionAnswers[question.id]);
                            default:
                              throw Error();
                          }
                        },
                      ),
                    );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

class ExamMarkForm extends StatefulWidget {
  final Course course;
  final Exam exam;
  final User student;

  const ExamMarkForm(
      {Key? key,
      required this.course,
      required this.exam,
      required this.student})
      : super(key: key);

  @override
  _ExamMarkFormState createState() => _ExamMarkFormState();
}

class _ExamMarkFormState extends State<ExamMarkForm> {
  bool _isLoading = false;
  final _markFormKey = GlobalKey<FormState>();
  final _markController = TextEditingController();
  final _feedbackController = TextEditingController();

  String? _validateMark(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a mark';
    }

    int numericMark = int.parse(value);

    if (numericMark < 1 || numericMark > 10) {
      return 'Please enter a value between 1 and 10';
    }

    return null;
  }

  Future<void> _markExam() async {
    setState(() {
      _isLoading = true;
    });
    if (_markFormKey.currentState!.validate()) {
      Auth auth = Provider.of<Auth>(context, listen: false);
      Map<String, dynamic> result = await Server.markExam(
          auth,
          widget.course.courseID,
          widget.exam.examID,
          widget.student.userID!,
          int.parse(_markController.text),
          _feedbackController.text);

      if (!mounted) return;

      if (result['error'] != null) {
        final snackBar = SnackBar(content: Text(result['error']));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        Navigator.pop(context);
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mark',
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(height: 16.0),
          Form(
            key: _markFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _feedbackController,
                  minLines: 3,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Write your feedback here...',
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _markController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: _validateMark,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          border: OutlineInputBorder(),
                          hintText: '1 - 10',
                          labelText: 'Mark',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () {
                              _markExam();
                            },
                            child: const Text('SUBMIT'),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
