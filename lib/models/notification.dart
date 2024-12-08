import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  eventInvite,
  eventJoined,
  eventCancelled,
  eventReminder,
  eventUpdated,
  message,
}

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final String? eventId;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.eventId,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => NotificationType.message,
      ),
      eventId: data['eventId'],
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.toString(),
      'eventId': eventId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
} 