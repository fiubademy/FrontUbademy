import 'package:fiubademy/src/models/course.dart';
import 'package:fiubademy/src/models/exam.dart';
import 'package:fiubademy/src/models/question.dart';
import 'package:fiubademy/src/services/auth.dart';
import 'package:fiubademy/src/services/server.dart';
import 'package:fiubademy/src/widgets/exam_cards.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuestionAnswer {
  final String _questionID;
  final String _answer;

  QuestionAnswer(String questionID, String answer)
      : _questionID = questionID,
        _answer = answer;

  String get questionID => _questionID;
  String get answer => _answer;
}

class ExamSolutionPage extends StatelessWidget {
  final Exam exam;
  final Course course;

  const ExamSolutionPage({Key? key, required this.exam, required this.course})
      : super(key: key);

  Future<Map<String, dynamic>> _loadExamMark(context) async {
    Auth auth = Provider.of<Auth>(context, listen: false);
    return Server.getExamMark(auth, course.courseID, exam.examID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(exam.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder(
                future: _loadExamMark(context),
                builder:
                    (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const SizedBox.shrink();
                    default:
                      if (snapshot.hasError) {
                        return const SizedBox.shrink();
                      }
                      if (snapshot.data!['error'] != null) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Feedback from Last Attempt',
                                  style: Theme.of(context).textTheme.headline6),
                            ),
                            const SizedBox(height: 16.0),
                            TextField(
                              enabled: false,
                              controller: TextEditingController(
                                  text: snapshot.data!['content']['comments']),
                              minLines: 3,
                              maxLines: null,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            TextField(
                              enabled: false,
                              controller: TextEditingController(
                                  text: '${snapshot.data!['content']['mark']}'),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 16.0,
                                ),
                                border: OutlineInputBorder(),
                                labelText: 'Mark',
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            const Center(
                              child: Text(
                                'You may submit a new response if you wish to increase your mark or make corrections.',
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Divider(),
                            ),
                          ],
                        ),
                      );
                  }
                },
              ),
              ExamSolutionForm(exam: exam, course: course),
            ],
          ),
        ),
      ),
    );
  }
}

class ExamSolutionForm extends StatefulWidget {
  final Exam exam;
  final Course course;

  const ExamSolutionForm({Key? key, required this.exam, required this.course})
      : super(key: key);

  @override
  _ExamSolutionFormState createState() => _ExamSolutionFormState();
}

class _ExamSolutionFormState extends State<ExamSolutionForm> {
  bool _isLoading = false;
  final List<QuestionAnswer> _answers = [];
  final _answerFormKey = GlobalKey<FormState>();

  void _sendSolution() async {
    setState(() {
      _isLoading = true;
    });

    _answers.clear();
    _answerFormKey.currentState!.save();
    if (_answers.length != widget.exam.questions.length) {
      const snackBar =
          SnackBar(content: Text('Unknown error. Please try again'));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    Auth auth = Provider.of<Auth>(context, listen: false);
    for (var answer in _answers) {
      String? result = await Server.submitQuestionAnswer(
          auth,
          widget.course.courseID,
          widget.exam.examID,
          answer.questionID,
          answer.answer);
      if (result != null) {
        final snackBar = SnackBar(content: Text(result));
        if (!mounted) continue;
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget _buildQuestionCard(index) {
    Question question = widget.exam.questions[index];
    switch (question.type) {
      case 'Development':
        return DevelopmentQuestionCard(
          question: question,
          index: index,
          onSaved: (newValue) {
            newValue ??= "Unanswered";
            _answers.add(QuestionAnswer(question.id!, newValue));
          },
        );
      case 'True or False':
        return TrueOrFalseQuestionCard(
          question: question,
          index: index,
          onSaved: (newValue) {
            String answer = 'Unanswered';
            if (newValue != null) {
              answer = newValue ? 'True' : 'False';
            }
            _answers.add(QuestionAnswer(question.id!, answer));
          },
        );
      case 'Multiple Choice':
        return MultipleChoiceQuestionCard(
          question: question,
          index: index,
          initialValue: {for (var item in question.options) item: false},
          onSaved: (Map<String, bool>? newValue) {
            String answer = 'Unanswered';
            if (newValue != null) {
              for (var option in newValue.keys) {
                if (newValue[option]!) {
                  answer += ';$option';
                }
              }
            }
            _answers.add(QuestionAnswer(question.id!, answer));
          },
        );
      case 'Single Choice':
        return SingleChoiceQuestionCard(
          question: question,
          index: index,
          onSaved: (newValue) {
            String answer = newValue ?? 'Unanswered';
            _answers.add(QuestionAnswer(question.id!, answer));
          },
        );
      default:
        throw Error();
    }
  }

  _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 0),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ElevatedButton(
              onPressed: () {
                showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Submit Answer'),
                    content: const Text(
                        'Are you sure you want to submit your answer to this exam?\n\nPlease, make sure you double-checked your answers'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('CANCEL'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _sendSolution();
                          Navigator.pop(context);
                        },
                        child: const Text('SUBMIT'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('SUBMIT ANSWER'),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _answerFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          //padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
          children: [
            const SizedBox(height: 24.0),
            for (int i = 0; i < widget.exam.questions.length; i++)
              _buildQuestionCard(i),
            _buildSubmitButton(),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
