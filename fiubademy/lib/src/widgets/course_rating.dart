import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CourseRating extends StatelessWidget {
  final double _ratingAvg;
  final int _ratingCount;

  const CourseRating({Key? key, required double avg, required int count})
      : _ratingAvg = avg,
        _ratingCount = count,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RatingBarIndicator(
          rating: _ratingAvg,
          itemSize: 24,
          itemBuilder: (context, index) =>
              Icon(Icons.star, color: Colors.amber),
        ),
        const SizedBox(width: 8.0),
        Text(
          _ratingAvg.toString(),
          style: Theme.of(context).textTheme.subtitle1,
        ),
        const Spacer(),
        Text(
          '($_ratingCount reviews)',
          style: Theme.of(context).textTheme.subtitle1,
        )
      ],
    );
  }
}
