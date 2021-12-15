import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Question {
  String _type;
  String _description;
  List<String> _options;

  Question()
      : _type = 'Development',
        _description = "",
        _options = [];

  static List<String> get types =>
      ['Development', 'Multiple Choice', 'Single Choice', 'True or False'];

  String get type => _type;

  set type(String newType) {
    _type = newType;
    _options.clear();
  }

  set description(String newDescription) {
    _description = newDescription;
  }

  List<String> get options => _options;

  addOption(String newOption) {
    if (_type == 'Development' || _type == 'True or False') {
      throw Error();
    }

    if (_options.contains(newOption)) {
      return;
    }

    _options.add(newOption);
  }

  removeOptionAt(int index) {
    if (_type == 'Development' || _type == 'True or False') {
      throw Error();
    }

    _options.removeAt(index);
  }
}

class ExamCreationPage extends StatefulWidget {
  const ExamCreationPage({Key? key}) : super(key: key);

  @override
  _ExamCreationPageState createState() => _ExamCreationPageState();
}

class _ExamCreationPageState extends State<ExamCreationPage> {
  bool _isLoading = false;
  final List<Question> _questions = [Question()];
  final List<Question> _newQuestions = [];
  final List<Question> _deletedQuestions = [];
  final _formKey = GlobalKey<FormState>();
  Map<int, TextEditingController> optionControllers = {};

  @override
  void initState() {
    super.initState();
  }

  void _saveExam() {
    setState(() {
      _isLoading = true;
    });
    if (!_formKey.currentState!.validate()) {}

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Exam'), actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.save))
      ]),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_rounded),
        onPressed: () {
          setState(() {
            _newQuestions.add(Question());
          });
        },
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: Scrollbar(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
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
              ElevatedButton(
                onPressed: () {
                  _saveExam();
                },
                child: const Text('CREATE'),
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
          validator: (question) => 'ERROR',
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
                    const TextField(
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Description',
                      ),
                    ),
                    if (state.value!.type == 'Single Choice' ||
                        state.value!.type == 'Multiple Choice') ...[
                      const SizedBox(height: 24.0),
                      Text('Options',
                          style: Theme.of(state.context).textTheme.subtitle1),
                      const SizedBox(height: 16.0),
                      for (int i = 0; i < state.value!.options.length; i++)
                        Row(
                          children: [
                            Text(state.value!._options[i]),
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
