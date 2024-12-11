import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementBadge {
  final String id;
  final String name;
  final String icon;
  final String description;

  const AchievementBadge({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });

  factory AchievementBadge.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AchievementBadge(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'description': description,
    };
  }
} 