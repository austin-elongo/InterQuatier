import 'package:flutter/material.dart';
import 'package:interquatier/models/review.dart';
import 'package:intl/intl.dart';

class ReviewItem extends StatelessWidget {
  final Review review;

  const ReviewItem({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(review.text ?? ''),
      subtitle: Text(
        'Posted on ${DateFormat.yMMMd().format(review.createdAt)}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
} 