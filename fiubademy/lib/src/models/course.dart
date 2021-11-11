class Course {
  String _courseID;

  Course._create(String courseID) : _courseID = courseID;

  static Future<Course> create(
      String courseID, Future<Map<String, dynamic>> courseData) async {
    Course course = Course._create(courseID);
    return course;
  }
}
