import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:interquatier/models/rating.dart';

final ratingsProvider = StreamProvider.autoDispose
    .family<List<Rating>, ({String targetId, String targetType})>((ref, params) {
  return FirebaseFirestore.instance
      .collection('ratings')
      .where('targetId', isEqualTo: params.targetId)
      .where('targetType', isEqualTo: params.targetType)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Rating.fromFirestore(doc)).toList());
});

final averageRatingProvider = StreamProvider.autoDispose
    .family<double, ({String targetId, String targetType})>((ref, params) {
  return FirebaseFirestore.instance
      .collection('ratings')
      .where('targetId', isEqualTo: params.targetId)
      .where('targetType', isEqualTo: params.targetType)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isEmpty) return 0.0;
    final total = snapshot.docs.fold<double>(
        0.0, (sum, doc) => sum + (doc.data()['rating'] ?? 0.0));
    return total / snapshot.docs.length;
  });
});

class RatingService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> addRating(Rating rating) async {
    await _firestore.collection('ratings').add(rating.toFirestore());
  }

  Future<void> updateRating(Rating rating) async {
    await _firestore.collection('ratings').doc(rating.id).update(rating.toFirestore());
  }

  Future<void> deleteRating(String ratingId) async {
    await _firestore.collection('ratings').doc(ratingId).delete();
  }
}

final ratingServiceProvider = Provider<RatingService>((ref) {
  return RatingService();
}); 