import 'package:interquatier/models/user_profile.dart';
import 'package:interquatier/models/relationship_badge.dart';

class Relationship {
  final String id;
  final UserProfile user;
  final RelationshipBadge badge;
  final bool isReceiver;

  const Relationship({
    required this.id,
    required this.user,
    required this.badge,
    required this.isReceiver,
  });
} 