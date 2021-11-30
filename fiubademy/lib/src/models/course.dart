import 'package:fiubademy/src/services/server.dart';

class Course {
  // General data
  String _courseID;
  String _title;
  int _minSubscription;
  String _description;
  double _latitude;
  double _longitude;
  List<String> _tags;
  DateTime _creationDate;

  // Flags
  bool _blocked;
  bool _open;

  // Owner data
  String _ownerID;
  String _ownerName;

  // Rating data
  int _ratingCount;
  double _ratingAvg;

  Course._create(String courseID, Map<String, dynamic> courseData)
      : _courseID = courseID,
        _title = courseData['name'],
        _ownerID = courseData['ownerID'],
        _ownerName = courseData['ownerName'],
        _minSubscription = courseData['sub_level'],
        _description = courseData['description'],
        _latitude = courseData['latitude'],
        _longitude = courseData['longitude'],
        _tags = courseData['hashtags'],
        _creationDate = courseData['time_created'],
        _blocked = courseData['blocked'],
        _public = courseData['in_edition'],
        _ratingCount = courseData['ratingCount'],
        _ratingAvg = courseData['ratingAvg'];

  static Future<Course> create(
      String courseID, Future<Map<String, dynamic>> courseData) async {
    Course course = Course._create(courseID, await courseData);
    return course;
  }

  String get title => _title;
  String get description => _description;

  String get minSubscriptionName {
    switch (_minSubscription) {
      case 1:
        return 'Standard';
      case 2:
        return 'Premium';
      default:
        return 'Free';
    }
  }

  String get stateName {
    if (_blocked) return 'Blocked';
    if (_open) return 'Open';
    return 'To be published';
  }

  List<String> get tags => _tags;

  int get ratingCount => _ratingCount;
  double get ratingAvg => _ratingAvg;
}
