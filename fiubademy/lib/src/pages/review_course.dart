import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewCoursePage extends StatelessWidget {
  const ReviewCoursePage({Key? key}) : super(key: key);

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
                RatingBar.builder(
                  minRating: 1.0,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {},
                ),
                const SizedBox(height: 32.0),
                const TextField(
                  minLines: 3,
                  maxLines: null,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'Write a review...',
                  ),
                ),
                const SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('SUBMIT'),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
