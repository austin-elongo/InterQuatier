import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  final String id;
  final String userId;
  final String targetId;  // Can be eventId, rentalId, userId etc.
  final String targetType;  // 'event', 'rental', 'user', etc.
  final double rating;
  final String? review;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;  // Additional type-specific data

  Rating({
    required this.id,
    required this.userId,
    required this.targetId,
    required this.targetType,
    required this.rating,
    this.review,
    required this.createdAt,
    this.metadata,
  });

  factory Rating.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Rating(
      id: doc.id,
      userId: data['userId'] ?? '',
      targetId: data['targetId'] ?? '',
      targetType: data['targetType'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      review: data['review'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'targetId': targetId,
      'targetType': targetType,
      'rating': rating,
      'review': review,
      'createdAt': Timestamp.fromDate(createdAt),
      'metadata': metadata,
    };
  }
} 