import 'package:fiubademy/src/services/server.dart';

class Course {
  String _courseID;
  String _courseTitle;
  String _ownerID;
  String _ownerName;
  int _minSubscription;
  String _description;
  double _latitude;
  double _longitude;
  List<String> _hashtags;
  DateTime _creationDate;
  bool _blocked;
  bool _public;

  Course._create(String courseID, Map<String, dynamic> courseData)
      : _courseID = courseID,
        _courseTitle = courseData['name'],
        _ownerID = courseData['ownerID'],
        _ownerName = courseData['ownerName'],
        _minSubscription = courseData['sub_level'],
        _description = courseData['description'],
        _latitude = courseData['latitude'],
        _longitude = courseData['longitude'],
        _hashtags = courseData['hashtags'],
        _creationDate = courseData['time_created'],
        _blocked = courseData['blocked'],
        _public = courseData['in_edition'];

  static Future<Course> create(
      String courseID, Future<Map<String, dynamic>> courseData) async {
    Course course = Course._create(courseID, await courseData);
    return course;
  }
}
