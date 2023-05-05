import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingView extends StatelessWidget {
  final num? rating;

  const RatingView({
    Key? key,
    required this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: rating?.toDouble() ?? 0,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      unratedColor: Colors.white,
      itemBuilder: (context, _) => const SizedBox(
        width: 30,
        height: 30,
        child: Icon(
          Icons.star,
          color: Colors.amber,
        ),
      ),
      itemSize: 20,
      onRatingUpdate: (rating) {},
      ignoreGestures: true,
    );
  }
}
