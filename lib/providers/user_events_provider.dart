import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:interquatier/models/event.dart';
import 'package:interquatier/models/achievement_badge.dart';

final userPastEventsProvider = StreamProvider.family<List<Event>, String>((ref, userId) {
  final now = DateTime.now();
  
  return FirebaseFirestore.instance
      .collection('events')
      .where('participants', arrayContains: userId)
      .where('date', isLessThan: now)
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Event.fromFirestore(doc))
          .toList());
});

final userHostedEventsProvider = StreamProvider.family<List<Event>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('events')
      .where('hostId', isEqualTo: userId)
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Event.fromFirestore(doc))
          .toList());
});

final userBadgesProvider = StreamProvider.family<List<AchievementBadge>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('user_badges')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => AchievementBadge.fromFirestore(doc))
          .toList());
}); 