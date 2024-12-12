import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/providers/rating_provider.dart';

class RatingDisplay extends ConsumerWidget {
  final String targetId;
  final String targetType;
  final double size;
  final bool showCount;

  const RatingDisplay({
    super.key,
    required this.targetId,
    required this.targetType,
    this.size = 24,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingAsync = ref.watch(averageRatingProvider((
      targetId: targetId,
      targetType: targetType,
    )));
    final ratingsAsync = ref.watch(ratingsProvider((
      targetId: targetId,
      targetType: targetType,
    )));

    return ratingAsync.when(
      data: (rating) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: size,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (showCount)
            ratingsAsync.when(
              data: (ratings) => Text(
                ' (${ratings.length})',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
        ],
      ),
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Icon(Icons.error),
    );
  }
} 