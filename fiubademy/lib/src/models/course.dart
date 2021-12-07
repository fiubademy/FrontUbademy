class Course {
  // General data
  final String _courseID;
  final String _title;
  final int _minSubscription;
  final String _description;
  final String _category;
  final double _latitude;
  final double _longitude;
  final List<String> _tags;
  final DateTime _creationDate;

  // Flags
  final bool _blocked;
  final bool _open;
  bool _isEnrolled;

  // Owner data
  final String _ownerID;
  final String _ownerName;

  // Rating data
  final int _ratingCount;
  final double _ratingAvg;

  Course.fromMap(Map<String, dynamic> courseData)
      : _courseID = courseData['id'],
        _title = courseData['name'],
        _ownerID = courseData['ownerId'],
        _ownerName = courseData['ownerName'],
        _minSubscription = courseData['sub_level'],
        _description = courseData['description'],
        _category = 'Hardcoded Category',
        _latitude = courseData['latitude'],
        _longitude = courseData['longitude'],
        _tags = List<String>.from(courseData['hashtags']),
        _creationDate = DateTime.parse(courseData['time_created']),
        _blocked = courseData['blocked'],
        _open = !(courseData['in_edition']),
        _ratingCount = courseData['ratingCount'],
        _ratingAvg = courseData['ratingAvg'] ?? 0,
        _isEnrolled = courseData['isEnrolled'];

/*
  static Course create2(String courseID, Map<String, dynamic> courseData) {
    /*
    Course course = Course._create(courseData);
    return course;*/
  }

  static Future<Course> create(
      String courseID, Future<Map<String, dynamic>> courseData) async {
        
    Course course = Course._create(await courseData);
    return course;
  }*/

  static List<String> categories() => [
        'Arts & Crafts',
        'Cooking',
        'Design',
        'Business',
        'Economics & Finance',
        'Health & Fitness',
        'Humanities',
        'Languages',
        'Music',
        'Office Productivity',
        'Personal Development',
        'Photography & Video',
        'Science',
        'Technology & Software',
      ];

  static List<String> subscriptionNames() => ['Free', 'Standard', 'Premium'];
  static int? subscriptionLevelFromName(String subName) {
    switch (subName) {
      case 'Free':
        return 0;
      case 'Standard':
        return 1;
      case 'Premium':
        return 2;
      default:
        return null;
    }
  }

  String get courseID => _courseID;
  String get title => _title;
  String get description => _description;
  String get category => _category;
  String get ownerID => _ownerID;
  String get ownerName => _ownerName;

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

  bool get isEnrolled => _isEnrolled;

  List<String> get tags => _tags;

  int get ratingCount => _ratingCount;
  double get ratingAvg => _ratingAvg;

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

  double get latitude => _latitude;
  double get longitude => _longitude;

  set isEnrolled(bool isEnrolled) => _isEnrolled = isEnrolled;
}
