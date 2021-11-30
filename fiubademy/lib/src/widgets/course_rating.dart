import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CourseRating extends StatelessWidget {
  const CourseRating({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RatingBarIndicator(
          rating: 4.3,
          itemSize: 24,
          itemBuilder: (context, index) =>
              Icon(Icons.star, color: Colors.amber),
        ),
        const SizedBox(width: 8.0),
        Text(
          '4.3',
          style: Theme.of(context).textTheme.subtitle1,
        ),
        const Spacer(),
        Text(
          '(37 reviews)',
          style: Theme.of(context).textTheme.subtitle1,
        )
      ],
    );
  }
}
