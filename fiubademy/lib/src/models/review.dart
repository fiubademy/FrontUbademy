import 'package:ubademy/src/services/user.dart';

class Review {
  final User _author;
  final int _rating;
  final String _description;

  Review(User author, int rating, String description)
      : _author = author,
        _rating = rating,
        _description = description;

  Review.fromMap(Map<String, dynamic> reviewData)
      : _author = reviewData['author'],
        _rating = reviewData['rating'],
        _description = reviewData['description'];

  User get author => _author;
  int get rating => _rating;
  String get description => _description;
}
