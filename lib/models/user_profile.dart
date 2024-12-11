import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String displayName;
  final String? photoUrl;
  final String email;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  UserProfile({
    required this.id,
    required this.displayName,
    this.photoUrl,
    required this.email,
    required this.createdAt,
    this.metadata,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      email: data['email'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'photoUrl': photoUrl,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'metadata': metadata,
    };
  }
} 