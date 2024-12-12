import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/models/rating.dart';
import 'package:interquatier/providers/rating_provider.dart';
import 'package:interquatier/providers/auth_provider.dart';

class RatingInput extends ConsumerStatefulWidget {
  final String targetId;
  final String targetType;
  final Map<String, dynamic>? metadata;
  final VoidCallback? onRatingSubmitted;

  const RatingInput({
    super.key,
    required this.targetId,
    required this.targetType,
    this.metadata,
    this.onRatingSubmitted,
  });

  @override
  ConsumerState<RatingInput> createState() => _RatingInputState();
}

class _RatingInputState extends ConsumerState<RatingInput> {
  double _rating = 0;
  final _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    final user = ref.read(authProvider);
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to rate')),
        );
      }
      return;
    }

    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final rating = Rating(
        id: '',
        userId: user.uid,
        targetId: widget.targetId,
        targetType: widget.targetType,
        rating: _rating,
        review: _reviewController.text.isNotEmpty ? _reviewController.text : null,
        createdAt: DateTime.now(),
        metadata: widget.metadata,
      );

      await ref.read(ratingServiceProvider).addRating(rating);
      
      if (mounted) {
        Navigator.pop(context);
        widget.onRatingSubmitted?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Rate your experience',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                icon: Icon(
                  index < _rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reviewController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Write a review (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSubmitting ? null : _submitRating,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
} 