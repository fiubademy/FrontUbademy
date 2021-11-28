import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Questions extends ChangeNotifier {
  final List<String> _questions;

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
              Provider.of<Questions>(context, listen: false).add("Hola");
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
                return QuestionEdition(
                  index: index,
                );
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

  const QuestionEdition({Key? key, required this.index, this.callback})
      : super(key: key);

  @override
  _QuestionEditionState createState() => _QuestionEditionState();
}

class _QuestionEditionState extends State<QuestionEdition> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Text('Pregunta ${widget.index + 1}',
                    style: Theme.of(context).textTheme.headline6),
                Spacer(),
                IconButton(
                  onPressed: () {
                    Provider.of<Questions>(context, listen: false)
                        .removeAt(widget.index);
                  },
                  icon: Icon(Icons.delete),
                ),
              ],
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
      ),
    );
  }
}
