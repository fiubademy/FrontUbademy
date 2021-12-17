import 'package:fiubademy/src/models/question.dart';

class Exam {
  final String _examID;
  final String _title;
  final bool _inEdition;
  final List<Question> _questions;

  Exam.fromMap(Map<String, dynamic> examData)
      : _examID = examData['ExamID'],
        _title = examData['ExamTitle'],
        _inEdition = examData['Status'] == 'EDITION',
        _questions = List.generate(examData['Questions'].length, (index) {
          return Question.fromMap(examData['Questions'][index]);
        });

  String get examID => _examID;
  String get title => _title;
  bool get inEdition => _inEdition;
  List<Question> get questions => _questions;
}
