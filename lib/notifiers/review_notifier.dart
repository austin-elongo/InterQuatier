import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:interquatier/models/review.dart';

class ReviewNotifier extends StateNotifier<AsyncValue<List<Review>>> {
  final _firestore = FirebaseFirestore.instance;
  final String eventId;

  ReviewNotifier(this.eventId) : super(const AsyncValue.loading()) {
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('reviews')
          .get();

      final reviews = snapshot.docs.map((doc) {
        final data = doc.data();
        return Review(
          id: doc.id,
          userId: data['userId'],
          text: data['text'],
          audioUrl: data['audioUrl'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      }).toList();

      state = AsyncValue.data(reviews);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addAudioReview(String audioUrl) async {
    try {
      final review = Review(
        id: '',  // Firestore will generate this
        userId: '',  // TODO: Get from auth provider
        audioUrl: audioUrl,
        createdAt: DateTime.now(),
      );

      await addReview(review);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addReview(Review review) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('reviews')
          .add(review.toMap());

      await _loadReviews();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
} 