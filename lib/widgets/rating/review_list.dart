import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/models/rating.dart';
import 'package:interquatier/providers/rating_provider.dart';
import 'package:interquatier/providers/user_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReviewList extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final ratingsAsync = ref.watch(ratingsProvider((
          targetId: targetId,
          targetType: targetType,
        )));

        return ratingsAsync.when(
          data: (ratings) {
            if (ratings.isEmpty) {
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
                  itemCount: ratings.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    return ReviewItem(rating: ratings[index]);
                  },
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        );
      },
    );
  }
}

class ReviewItem extends ConsumerWidget {
  final Rating rating;

  const ReviewItem({
    super.key,
    required this.rating,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider(rating.userId));

    return userAsync.when(
      data: (user) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
                      ? Text(user.displayName[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        timeago.format(rating.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating.rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    );
                  }),
                ),
              ],
            ),
            if (rating.review != null) ...[
              const SizedBox(height: 8),
              Text(rating.review!),
            ],
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
} 