import 'package:fiubademy/src/models/question.dart';

class Exam {
  final String _examID;
  final String _title;
  final bool _inEdition;
  final List<Question> _questions;
  final DateTime _creationDate;

  Exam.fromMap(Map<String, dynamic> examData)
      : _examID = examData['ExamID'],
        _title = examData['ExamTitle'],
        _inEdition = examData['Status'] == 'EDITION',
        _questions = List.generate(examData['Questions'].length, (index) {
          return Question.fromMap(examData['Questions'][index]);
        }),
        _creationDate = DateTime.parse(examData['Date']);

  String get examID => _examID;
  String get title => _title;
  bool get inEdition => _inEdition;
  List<Question> get questions => _questions;
  DateTime get creationDate => _creationDate;
  int get creationDay => _creationDate.day;
  int get creationYear => _creationDate.year;
  String get creationMonthName {
    switch (_creationDate.month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        throw StateError('Invalid month number');
    }
  }
}
