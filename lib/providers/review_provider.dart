import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:interquatier/models/review.dart';
import 'package:interquatier/notifiers/review_notifier.dart';

final reviewProvider = StateNotifierProvider.family<ReviewNotifier, AsyncValue<List<Review>>, String>((ref, eventId) {
  return ReviewNotifier(eventId);
});

final audioReviewCountProvider = StreamProvider.family<int, String>((ref, eventId) {
  return FirebaseFirestore.instance
      .collection('reviews')
      .where('eventId', isEqualTo: eventId)
      .where('type', isEqualTo: 'audio')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
}); 