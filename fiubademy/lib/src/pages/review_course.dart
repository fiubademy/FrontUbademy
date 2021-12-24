import 'package:ubademy/src/models/course.dart';
import 'package:ubademy/src/models/review.dart';
import 'package:ubademy/src/services/auth.dart';
import 'package:ubademy/src/services/server.dart';
import 'package:ubademy/src/services/user.dart';
import 'package:ubademy/src/widgets/review_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class ReviewCoursePage extends StatefulWidget {
  final Course course;
  const ReviewCoursePage({Key? key, required this.course}) : super(key: key);

  @override
  _ReviewCoursePageState createState() => _ReviewCoursePageState();
}

class _ReviewCoursePageState extends State<ReviewCoursePage> {
  bool _isLoading = false;
  int _rating = 0;
  final _descriptionController = TextEditingController();

  void _submitReview() async {
    if (_rating < 1 || _rating > 5) {
      const snackBar = SnackBar(
        content: Text('Please select a rating to submit a review'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Submit Review'),
                content: const Text(
                    'Are you sure you want to send this review?\n\n Any existing reviews by you will be permanently deleted and replaced by this one'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text('CANCEL'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('SUBMIT'),
                  ),
                ]));
    confirmed ??= false;

    if (confirmed) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      Auth auth = Provider.of<Auth>(context, listen: false);
      String? result = await Server.submitReview(
          auth, widget.course.courseID, _rating, _descriptionController.text);
      if (result != null) {
        final snackBar = SnackBar(content: Text(result));
        scaffoldMessenger.showSnackBar(snackBar);
      } else {
        if (!mounted) return;
        Navigator.pop(context);
      }
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<Map<String, dynamic>> _getMyReview() {
    Auth auth = Provider.of<Auth>(context, listen: false);
    return Server.getMyReview(auth, widget.course.courseID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Ubademy'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
            child: Column(
              children: [
                FutureBuilder(
                  future: _getMyReview(),
                  builder:
                      (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const SizedBox.shrink();
                      default:
                        if (snapshot.hasError) {
                          return const SizedBox.shrink();
                        }

                        if (!snapshot.hasData || snapshot.data == null) {
                          return const SizedBox.shrink();
                        }

                        if (snapshot.data!['error'] != null) {
                          return const SizedBox.shrink();
                        }

                        final myReview = Review(
                            Provider.of<User>(context, listen: false),
                            snapshot.data!['rating'],
                            snapshot.data!['description'] ?? '');

                        return ReviewCard(review: myReview);
                    }
                  },
                ),
                const SizedBox(height: 24.0),
                RatingBar.builder(
                  minRating: 1.0,
                  itemBuilder: (context, index) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    _rating = rating.toInt();
                  },
                ),
                const SizedBox(height: 32.0),
                TextField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: null,
                  decoration: const InputDecoration(
                    filled: true,
                    hintText: 'Write a review...',
                  ),
                ),
                const SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () {
                            _submitReview();
                          },
                          child: const Text('SUBMIT'),
                        ),
                ),
              ],
            ),
          ),
        ));
  }
}
