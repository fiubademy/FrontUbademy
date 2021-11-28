import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Questions extends ChangeNotifier {
  final List<String> _questions;

  static const List<String> _types = [
    "Development",
    "Multiple Choice",
    "Single Choice",
    "True or False"
  ];

  Questions() : _questions = [];

  int get length => _questions.length;

  String operator [](int index) => _questions[index];

  void add(String newQuestion) {
    _questions.add(newQuestion);
    notifyListeners();
  }

  void removeAt(int index) {
    _questions.removeAt(index);
    notifyListeners();
  }

  static List<String> get types => _types;
}

class ExamCreationPage extends StatelessWidget {
  const ExamCreationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Questions(),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('New Exam')),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add_rounded),
            onPressed: () {
              Provider.of<Questions>(context, listen: false).add("Development");
            },
          ),
          body: const SafeArea(
            child: ExamEdition(),
          ),
        );
      },
    );
  }
}

class ExamEdition extends StatefulWidget {
  const ExamEdition({Key? key}) : super(key: key);

  @override
  _ExamEditionState createState() => _ExamEditionState();
}

class _ExamEditionState extends State<ExamEdition> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: Provider.of<Questions>(context).length,
              itemBuilder: (context, index) {
                return QuestionEdition(index: index);
              },
            ),
          )
        ],
      ),
    );
  }
}

class QuestionEdition extends StatefulWidget {
  final int index;
  final void Function()? callback;

  QuestionEdition({Key? key, required this.index, this.callback})
      : super(key: key);

  @override
  _QuestionEditionState createState() => _QuestionEditionState();
}

class _QuestionEditionState extends State<QuestionEdition> {
  String? _question;
  List<String> _options = [];
  var _newOptioncontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // TODO Use proper type and stuff
    // _question = Provider.of<Questions>(context, listen: false)[widget.index];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Pregunta ${widget.index + 1}',
                    style: Theme.of(context).textTheme.headline6),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Provider.of<Questions>(context, listen: false)
                        .removeAt(widget.index);
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            DropdownButton(
              value: _question,
              isExpanded: true,
              hint: const Text("Type"),
              items: Questions.types.map<DropdownMenuItem<String>>(
                (String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                },
              ).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  if (newValue != null && newValue != _question) {
                    _question = newValue;
                    _options.clear();
                  }
                });
              },
            ),
            const TextField(
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Description',
              ),
            ),
            if (_question == 'Single Choice' ||
                _question == 'Multiple Choice') ...[
              const SizedBox(height: 24.0),
              Text('Options', style: Theme.of(context).textTheme.subtitle1),
              const SizedBox(height: 16.0),
              for (int i = 0; i < _options.length; i++)
                Row(
                  children: [
                    Text(_options[i]),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _options.removeAt(i);
                        });
                      },
                      icon: const Icon(Icons.clear_rounded),
                    ),
                  ],
                ),
              TextField(
                controller: _newOptioncontroller,
                decoration: InputDecoration(
                  hintText: 'New option',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check_rounded),
                    onPressed: () {
                      setState(() {
                        if (_newOptioncontroller.text != '') {
                          _options.add(_newOptioncontroller.text);
                          _newOptioncontroller.clear();
                        }
                      });
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
