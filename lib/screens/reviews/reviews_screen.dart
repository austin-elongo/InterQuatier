import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/widgets/rating/rating_display.dart';
import 'package:interquatier/widgets/rating/review_list.dart';
import 'package:interquatier/widgets/rating/rating_input.dart';

class ReviewsScreen extends ConsumerWidget {
  final String targetId;
  final String targetType;
  final String title;

  const ReviewsScreen({
    super.key,
    required this.targetId,
    required this.targetType,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: RatingDisplay(
                  targetId: targetId,
                  targetType: targetType,
                  size: 32,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ReviewList(
              targetId: targetId,
              targetType: targetType,
              showHeader: false,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRatingInput(context),
        icon: const Icon(Icons.rate_review),
        label: const Text('Write Review'),
      ),
    );
  }

  void _showRatingInput(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: RatingInput(
          targetId: targetId,
          targetType: targetType,
        ),
      ),
    );
  }
} 