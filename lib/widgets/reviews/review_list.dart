import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/widgets/reviews/audio_player_widget.dart';
import 'package:interquatier/widgets/reviews/review_item.dart';
import 'package:interquatier/providers/review_provider.dart';

class ReviewList extends ConsumerWidget {
  final String targetId;
  final String targetType;
  final bool showHeader;

  const ReviewList({
    super.key,
    required this.targetId,
    required this.targetType,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewProvider(targetId));

    return reviewsAsync.when(
      data: (reviews) {
        if (reviews.isEmpty) {
          return const Center(
            child: Text('No reviews yet'),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Reviews',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final review = reviews[index];
                if (review.audioUrl?.isNotEmpty ?? false) {
                  return AudioPlayerWidget(
                    audioUrl: review.audioUrl!,
                    onError: (e) => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error playing audio: $e')),
                    ),
                  );
                }
                return ReviewItem(review: review);
              },
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
} 