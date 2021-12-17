class Question {
  String? id;
  String _type;
  String description;
  final List<String> _options;

  Question()
      : _type = 'Development',
        description = "",
        _options = [];

  Question.fromMap(Map<String, dynamic> questionData)
      : id = questionData['QuestionID'],
        _type = typeFromServer(questionData['QuestionType']),
        description = questionData['QuestionContent'],
        _options = (questionData['QuestionType'] == 'DES' ||
                questionData['QuestionType'] == 'VOF')
            ? []
            : List<String>.generate(
                questionData['ChoiceOptions'].length,
                (index) => questionData['ChoiceOptions'][index]['Content'],
              );

  static String typeFromServer(String serverType) {
    switch (serverType) {
      case 'DES':
        return 'Development';
      case 'MC':
        return 'Multiple Choice';
      case 'SC':
        return 'Single Choice';
      case 'VOF':
        return 'True or False';
      default:
        throw Error();
    }
  }

  static List<String> get types =>
      ['Development', 'Multiple Choice', 'Single Choice', 'True or False'];

  String get type => _type;

  set type(String newType) {
    _type = newType;
    _options.clear();
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
