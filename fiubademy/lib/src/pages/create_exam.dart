import 'package:fiubademy/src/models/course.dart';
import 'package:fiubademy/src/models/question.dart';
import 'package:fiubademy/src/services/auth.dart';
import 'package:fiubademy/src/services/server.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExamCreationPage extends StatefulWidget {
  final Course course;
  final String? examID;
  final String? examTitle;
  final List<Question>? questions;

  const ExamCreationPage(
      {Key? key,
      required this.course,
      this.examID,
      this.examTitle,
      this.questions})
      : super(key: key);

  @override
  _ExamCreationPageState createState() => _ExamCreationPageState();
}

class _ExamCreationPageState extends State<ExamCreationPage> {
  bool _isLoading = false;
  String? examID;
  List<Question> _questions = [];
  final List<Question> _newQuestions = [];
  final List<Question> _deletedQuestions = [];
  final _formKey = GlobalKey<FormState>();
  Map<int, TextEditingController> optionControllers = {};
  final _titleController = TextEditingController();

  @override
  void initState() {
    examID = widget.examID;
    if (widget.examTitle != null) _titleController.text = widget.examTitle!;
    _questions = widget.questions ?? [];
    super.initState();
  }

  void _saveExam() async {
    if (_isLoading) return;
    _isLoading = true;
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      _isLoading = false;
      return;
    }

    // No questions left
    if (_questions.isEmpty && _newQuestions.isEmpty) {
      const snackBar = SnackBar(
        content: Text('Please add at least one question'),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      _isLoading = false;
      return;
    }

    Auth auth = Provider.of<Auth>(context, listen: false);

    bool err = false;

    // New exam
    if (examID == null) {
      String title = _titleController.text;
      Map<String, dynamic> result = await Server.createExam(
        auth,
        widget.course.courseID,
        title,
      );
      if (result['error'] != null) {
        final snackBar = SnackBar(content: Text('${result['error']}'));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        _isLoading = false;
        return;
      } else {
        examID = result['content'];
      }
    } else {
      if (widget.examTitle != _titleController.text) {
        String? result = await Server.updateExam(
          auth,
          widget.course.courseID,
          examID!,
          _titleController.text,
        );
        if (result != null) {
          final snackBar = SnackBar(content: Text(result));
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          err = true;
        }
      }
    }

    if (examID == null) {
      throw Error();
    }

    // General case

    for (int i = 0; i < _deletedQuestions.length; i++) {
      print('Deleted questions: ${_deletedQuestions.length}');
      Question questionToDelete = _deletedQuestions.last;
      String? result = await Server.deleteExamQuestion(
        auth,
        widget.course.courseID,
        questionToDelete.id!,
      );
      if (result != null) {
        final snackBar = SnackBar(
          content: Text(result),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        err = true;
      } else {
        _deletedQuestions.removeLast();
      }
    }

    for (var question in _questions) {
      print('Existing questions: ${_questions.length}');
      String? result = await Server.updateExamQuestion(
          auth,
          widget.course.courseID,
          question.id!,
          question.type,
          question.description,
          question.options);
      if (result != null) {
        final snackBar = SnackBar(
          content: Text(result),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        err = true;
      }
    }

    for (int i = 0; i < _newQuestions.length; i++) {
      print('New Questions: ${_newQuestions.length}');
      Question question = _newQuestions.first;
      Map<String, dynamic> result = await Server.addExamQuestion(
        auth,
        widget.course.courseID,
        examID!,
        question.type,
        question.description,
        question.options,
      );
      if (result['error'] != null) {
        final snackBar = SnackBar(
          content: Text('${result['error']}'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        err = true;
      } else {
        question.id = result['content'];
        _questions.add(_newQuestions.removeAt(0));
      }
    }

    if (!err) {
      const snackBar = SnackBar(content: Text('Successfully saved the exam'));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            examID != null ? const Text('Edit Exam') : const Text('New Exam'),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: null,
            child: const Icon(Icons.save_rounded),
            onPressed: () {
              _saveExam();
            },
          ),
          const SizedBox(height: 16.0),
          FloatingActionButton(
            heroTag: null,
            child: const Icon(Icons.add_rounded),
            onPressed: () {
              setState(() {
                _newQuestions.add(Question());
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                child: TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Exam Title',
                    hintText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Title must not be empty';
                    }
                    return null;
                  },
                ),
              ),
              Expanded(
                child: Scrollbar(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                    itemCount: _questions.length + _newQuestions.length,
                    itemBuilder: (context, index) {
                      final optionController = optionControllers.putIfAbsent(
                          index, () => TextEditingController());
                      if (index < _questions.length) {
                        return QuestionEdition(
                          initialValue: _questions[index],
                          optionController: optionController,
                          onDelete: () => setState(() {
                            _deletedQuestions.add(_questions.removeAt(index));
                          }),
                          index: index,
                        );
                      } else {
                        return QuestionEdition(
                          initialValue:
                              _newQuestions[index - _questions.length],
                          optionController: optionController,
                          onDelete: () => setState(() {
                            _newQuestions.removeAt(index - _questions.length);
                          }),
                          index: index,
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in optionControllers.values) {
      controller.dispose();
    }
    _titleController.dispose();
    super.dispose();
  }
}

class QuestionEdition extends FormField<Question> {
  QuestionEdition({
    Key? key,
    Question? initialValue,
    required TextEditingController optionController,
    VoidCallback? onDelete,
    required int index,
  }) : super(
          key: key,
          initialValue: initialValue ?? Question(),
          validator: (question) {
            if (question!.description.isEmpty) {
              return 'Description must not be empty';
            }
            if (question.type == 'Development' ||
                question.type == 'True or False') {
              return null;
            }
            if (question.options.length < 2) {
              return 'Options must be two or more';
            }
          }, // FIXME Poner algo interesante
          builder: (FormFieldState<Question> state) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Question ${index + 1}',
                            style: Theme.of(state.context).textTheme.headline6),
                        const Spacer(),
                        IconButton(
                          onPressed: () => onDelete?.call(),
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButton(
                      value: state.value!.type,
                      isExpanded: true,
                      hint: const Text("Type"),
                      items: Question.types.map<DropdownMenuItem<String>>(
                        (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        },
                      ).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null && newValue != state.value!.type) {
                          state.value!.type = newValue;
                          state.didChange(state.value);
                        }
                      },
                    ),
                    TextField(
                      controller:
                          TextEditingController(text: state.value!.description),
                      maxLines: null,
                      onChanged: (String? newValue) {
                        if (newValue != null &&
                            newValue != state.value!.description) {
                          state.value!.description = newValue;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Description',
                        errorText:
                            (state.hasError && state.value!.description.isEmpty)
                                ? 'Description must not be empty'
                                : null,
                      ),
                    ),
                    if (state.value!.type == 'Single Choice' ||
                        state.value!.type == 'Multiple Choice') ...[
                      const SizedBox(height: 24.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Options',
                              style:
                                  Theme.of(state.context).textTheme.subtitle1),
                          if (state.hasError && state.value!.options.length < 2)
                            Text('Options must be two or more',
                                style: TextStyle(
                                    color: Theme.of(state.context)
                                        .colorScheme
                                        .error)),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      for (int i = 0; i < state.value!.options.length; i++)
                        Row(
                          children: [
                            Text(state.value!.options[i]),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                state.value!.removeOptionAt(i);
                                state.didChange(state.value);
                              },
                              icon: const Icon(Icons.clear_rounded),
                            ),
                          ],
                        ),
                      TextField(
                        controller: optionController,
                        decoration: InputDecoration(
                          hintText: 'New option',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.check_rounded),
                            onPressed: () {
                              if (optionController.text != '') {
                                state.value!.addOption(optionController.text);
                                optionController.clear();
                                state.didChange(state.value);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
}
