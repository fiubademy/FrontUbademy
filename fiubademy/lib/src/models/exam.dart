import 'package:fiubademy/src/models/question.dart';

class Exam {
  final String _examID;
  final String _title;
  final bool _inEdition;
  final List<Question> _questions;
  final String _creationDate;

  Exam.fromMap(Map<String, dynamic> examData)
      : _examID = examData['ExamID'],
        _title = examData['ExamTitle'],
        _inEdition = examData['Status'] == 'EDITION',
        _questions = List.generate(examData['Questions'].length, (index) {
          return Question.fromMap(examData['Questions'][index]);
        }),
        _creationDate = examData['Date'].split(' ')[0];

  String get examID => _examID;
  String get title => _title;
  bool get inEdition => _inEdition;
  List<Question> get questions => _questions;
  String get creationDate => _creationDate;
}
