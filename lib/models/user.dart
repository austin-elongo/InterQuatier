import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? bio;
  final List<String> interests;
  final List<String> joinedEvents;
  final List<String> pastEvents;
  final DateTime createdAt;
  final DateTime lastActive;

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.bio,
    this.interests = const [],
    this.joinedEvents = const [],
    this.pastEvents = const [],
    required this.createdAt,
    required this.lastActive,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      bio: data['bio'],
      interests: List<String>.from(data['interests'] ?? []),
      joinedEvents: List<String>.from(data['joinedEvents'] ?? []),
      pastEvents: List<String>.from(data['pastEvents'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActive: (data['lastActive'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'interests': interests,
      'joinedEvents': joinedEvents,
      'pastEvents': pastEvents,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? photoUrl,
    String? bio,
    List<String>? interests,
    List<String>? joinedEvents,
    List<String>? pastEvents,
    DateTime? lastActive,
  }) {
    return UserProfile(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      joinedEvents: joinedEvents ?? this.joinedEvents,
      pastEvents: pastEvents ?? this.pastEvents,
      createdAt: createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
} 