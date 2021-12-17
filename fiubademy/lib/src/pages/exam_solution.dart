import 'package:fiubademy/src/models/exam.dart';
import 'package:fiubademy/src/models/question.dart';
import 'package:fiubademy/src/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class QuestionAnswer {
  String _questionID;
  String _answer;

  QuestionAnswer(String questionID, String answer)
      : _questionID = questionID,
        _answer = answer;
}

class ExamSolutionPage extends StatelessWidget {
  final Exam exam;
  List<QuestionAnswer> _answers = [];

  ExamSolutionPage({Key? key, required this.exam})
      : _answers = [],
        super(key: key);

  void _sendSolution() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam'),
      ),
      body: SafeArea(
        child: Form(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
            itemCount: exam.questions.length + 1,
            itemBuilder: (context, index) {
              if (index == exam.questions.length) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 0),
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('SEND ANSWER'),
                  ),
                );
              }
              Question question = exam.questions[index];
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
                    initialValue: {
                      for (var item in question.options) item: false
                    },
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
            },
          ),
        ),
      ),
    );
  }
}

class DevelopmentQuestionCard extends StatelessWidget {
  final Question question;
  final int index;
  final FormFieldSetter<String>? onSaved;

  const DevelopmentQuestionCard({
    Key? key,
    required this.question,
    required this.index,
    this.onSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
            child: Text('Question ${index + 1}',
                style: Theme.of(context).textTheme.headline6),
          ),
          ListTile(
              title: Text('${question.description}\n\nWrite your answer:')),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            child: TextFormField(
              onSaved: onSaved,
              maxLines: null,
              minLines: 2,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum TrueOrFalse { answerTrue, answerFalse }

class TrueOrFalseQuestionCard extends FormField<bool> {
  TrueOrFalseQuestionCard({
    Key? key,
    required Question question,
    required int index,
    FormFieldSetter<bool>? onSaved,
  }) : super(
          key: key,
          onSaved: onSaved,
          builder: (FormFieldState<bool> state) {
            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                    child: Builder(builder: (context) {
                      return Text('Question ${index + 1}',
                          style: Theme.of(context).textTheme.headline6);
                    }),
                  ),
                  ListTile(
                      title: Text('${question.description}\n\nYour answer:')),
                  RadioListTile<bool>(
                    title: const Text('True'),
                    value: true,
                    groupValue: state.value,
                    onChanged: (value) {
                      state.didChange(value);
                    },
                  ),
                  RadioListTile<bool>(
                    title: const Text('False'),
                    value: false,
                    groupValue: state.value,
                    onChanged: (value) {
                      state.didChange(value);
                    },
                  ),
                ],
              ),
            );
          },
        );
}

class MultipleChoiceQuestionCard extends FormField<Map<String, bool>> {
  MultipleChoiceQuestionCard({
    Key? key,
    required Question question,
    required int index,
    FormFieldSetter<Map<String, bool>>? onSaved,
    FormFieldValidator<Map<String, bool>>? validator,
    required Map<String, bool> initialValue,
  }) : super(
          key: key,
          onSaved: onSaved,
          validator: validator,
          initialValue: initialValue,
          builder: (FormFieldState<Map<String, bool>> state) {
            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                    child: Builder(
                      builder: (context) {
                        return Text('Question ${index + 1}',
                            style: Theme.of(context).textTheme.headline6);
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(
                        '${question.description}\n\nSelect all the correct options:'),
                  ),
                  Builder(
                    builder: (context) {
                      final theme = Theme.of(context);
                      final oldCheckboxTheme = theme.checkboxTheme;

                      final newCheckBoxTheme = oldCheckboxTheme.copyWith(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3)),
                      );
                      return Theme(
                        data: theme.copyWith(checkboxTheme: newCheckBoxTheme),
                        child: Column(
                          children: [
                            for (final option in question.options)
                              CheckboxListTile(
                                title: Text(option),
                                value: state.value![option],
                                onChanged: (checked) {
                                  if (checked == null) return;
                                  state.value![option] = checked;
                                  state.didChange(state.value);
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
}

class SingleChoiceQuestionCard extends FormField<String> {
  SingleChoiceQuestionCard({
    Key? key,
    required Question question,
    required int index,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
  }) : super(
          key: key,
          onSaved: onSaved,
          validator: validator,
          builder: (FormFieldState<String> state) {
            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                    child: Builder(
                      builder: (context) {
                        return Text('Question ${index + 1}',
                            style: Theme.of(context).textTheme.headline6);
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(
                        '${question.description}\n\nSelect the correct option:'),
                  ),
                  Builder(
                    builder: (context) {
                      final theme = Theme.of(context);
                      final oldCheckboxTheme = theme.checkboxTheme;

                      final newCheckBoxTheme = oldCheckboxTheme.copyWith(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3)),
                      );
                      return Theme(
                        data: theme.copyWith(checkboxTheme: newCheckBoxTheme),
                        child: Column(
                          children: [
                            for (final option in question.options)
                              RadioListTile<String>(
                                title: Text(option),
                                value: option,
                                groupValue: state.value,
                                onChanged: (selected) {
                                  state.didChange(selected);
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
}
