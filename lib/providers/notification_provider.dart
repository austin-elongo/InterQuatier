import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/models/notification.dart';
import 'package:interquatier/providers/auth_provider.dart';

final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final user = ref.watch(authProvider);
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('notifications')
      .where('userId', isEqualTo: user.uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => AppNotification.fromFirestore(doc))
        .toList();
  });
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.when(
    data: (notifications) =>
        notifications.where((notification) => !notification.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

class NotificationService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    String? eventId,
  }) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.toString(),
      'eventId': eventId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }
} 