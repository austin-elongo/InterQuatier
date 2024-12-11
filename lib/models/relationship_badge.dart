import 'package:cloud_firestore/cloud_firestore.dart';

enum BadgeStatus {
  pending,
  accepted,
  rejected,
}

class RelationshipBadge {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String badgeType;  // e.g., 'father', 'mother', 'mentor'
  final BadgeStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? toPhoneNumber;  // Used when recipient isn't yet a member

  const RelationshipBadge({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.badgeType,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    this.toPhoneNumber,
  });

  factory RelationshipBadge.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RelationshipBadge(
      id: doc.id,
      fromUserId: data['fromUserId'],
      toUserId: data['toUserId'],
      badgeType: data['badgeType'],
      status: BadgeStatus.values.byName(data['status']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      respondedAt: data['respondedAt'] != null 
          ? (data['respondedAt'] as Timestamp).toDate()
          : null,
      toPhoneNumber: data['toPhoneNumber'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'badgeType': badgeType,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'toPhoneNumber': toPhoneNumber,
    };
  }
} 