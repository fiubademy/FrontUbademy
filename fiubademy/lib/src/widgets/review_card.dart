import 'package:fiubademy/src/widgets/icon_avatar.dart';
import 'package:flutter/material.dart';
import 'package:fiubademy/src/models/review.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  const ReviewCard({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            0.0, 16.0, 0.0, review.description.isEmpty ? 16.0 : 0.0),
        child: Column(
          children: [
            ListTile(
              leading: IconAvatar(
                  avatarID: review.author.avatarID, width: 48, height: 48),
              title: RatingBarIndicator(
                itemBuilder: (context, index) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemSize: 32,
                rating: review.rating.toDouble(),
              ),
              subtitle: Text(' by ${review.author.username}'),
            ),
            if (review.description.isNotEmpty)
              ListTile(
                title: Text(review.description),
              )
          ],
        ),
      ),
    );
  }
}
