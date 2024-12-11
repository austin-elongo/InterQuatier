import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:interquatier/models/relationship_badge.dart';
import 'package:interquatier/services/notification_service.dart';
import 'package:interquatier/services/sms_service.dart';

class RelationshipNotifier extends StateNotifier<AsyncValue<List<RelationshipBadge>>> {
  final _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService;
  final SMSService _smsService;

  RelationshipNotifier(this._notificationService, this._smsService) : super(const AsyncValue.loading());

  Future<void> createBadge({
    required String fromUserId,
    required String toUserId,
    required String badgeType,
    String? toPhoneNumber,
  }) async {
    try {
      final badge = RelationshipBadge(
        id: '',
        fromUserId: fromUserId,
        toUserId: toUserId,
        badgeType: badgeType,
        status: BadgeStatus.pending,
        createdAt: DateTime.now(),
        toPhoneNumber: toPhoneNumber,
      );

      final docRef = await _firestore.collection('relationships').add(badge.toFirestore());

      if (toPhoneNumber != null) {
        // Send SMS invite if user isn't registered
        await _smsService.sendInvite(
          phoneNumber: toPhoneNumber,
          message: 'Someone wants to connect with you on InterQuatier!',
          relationshipId: docRef.id,
        );
      } else {
        // Send in-app notification if user is registered
        await _notificationService.sendNotification(
          userId: toUserId,
          title: 'New Relationship Request',
          body: 'Someone wants to add you as their $badgeType',
          data: {
            'type': 'relationship_badge',
            'badgeId': docRef.id,
          },
        );
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> respondToBadge(String badgeId, bool accept) async {
    try {
      await _firestore.collection('relationships').doc(badgeId).update({
        'status': accept ? BadgeStatus.accepted.name : BadgeStatus.rejected.name,
        'respondedAt': FieldValue.serverTimestamp(),
      });

      // Notify the badge creator of the response
      final badge = await _firestore.collection('relationships').doc(badgeId).get();
      final badgeData = RelationshipBadge.fromFirestore(badge);

      await _notificationService.sendNotification(
        userId: badgeData.fromUserId,
        title: 'Badge Response',
        body: accept 
            ? 'Your relationship badge was accepted!'
            : 'Your relationship badge was declined.',
        data: {
          'type': 'badge_response',
          'badgeId': badgeId,
          'accepted': accept.toString(),
        },
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final relationshipProvider = StateNotifierProvider<RelationshipNotifier, AsyncValue<List<RelationshipBadge>>>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  final smsService = ref.watch(smsServiceProvider);
  return RelationshipNotifier(notificationService, smsService);
});

// Get all relationships for a user (both sent and received)
final userRelationshipsProvider = StreamProvider.family<List<RelationshipBadge>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('relationships')
      .where(Filter.or(
        Filter('fromUserId', isEqualTo: userId),
        Filter('toUserId', isEqualTo: userId),
      ))
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => RelationshipBadge.fromFirestore(doc)).toList());
});

// Get confirmed relationships only
final confirmedRelationshipsProvider = StreamProvider.family<List<RelationshipBadge>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('relationships')
      .where(Filter.or(
        Filter('fromUserId', isEqualTo: userId),
        Filter('toUserId', isEqualTo: userId),
      ))
      .where('status', isEqualTo: BadgeStatus.accepted.name)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => RelationshipBadge.fromFirestore(doc)).toList());
}); 