import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final double starSize;
  final Color filledColor;
  final Color unfilledColor;

  const RatingWidget({
    Key? key,
    required this.rating,
    this.starSize = 24.0,
    this.filledColor = Colors.amber,
    this.unfilledColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RatingBarIndicator(
      rating: rating.clamp(0.0, 5.0), // Ensures rating stays within range
      itemBuilder: (context, index) => Icon(
        Icons.star,
        color: filledColor,
      ),
      itemCount: 5,
      itemSize: starSize,
      unratedColor: unfilledColor,
      direction: Axis.horizontal,
    );
  }
}
