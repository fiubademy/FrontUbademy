class Course {
  final String _courseID;
  final String _name;
  final String _description;
  final String? _state;
  final int _subscriptionLevel;
  final double _rating;
  final int _reviewsCount;
  final List<String> _tags;

  const Course(String courseID, String name, String description, String? state,
      int subscriptionLevel, double rating, int reviewsCount, List<String> tags)
      : _courseID = courseID,
        _name = name,
        _description = description,
        _state = state,
        _subscriptionLevel = subscriptionLevel,
        _rating = rating,
        _reviewsCount = reviewsCount,
        _tags = tags;

  String get name => _name;
  String get description => _description;
  String get state => _state ?? 'You shouldn\'t see this!';
  String get subscriptionName {
    switch (_subscriptionLevel) {
      case 0:
        return 'No subscription';
      case 1:
        return 'Standard Subscription';
      case 2:
        return 'Premium Subscription';
      default:
        return 'No subscription';
    }
  }

  double get rating => _rating;
  int get reviewsCount => _reviewsCount;
  List<String> get tags => _tags;
}
