import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  eventInvite,
  eventJoined,
  eventCancelled,
  eventReminder,
  eventUpdated,
  message,
  relationshipRequest,
}

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final String? eventId;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.eventId,
    this.data,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      userId: data['userId'],
      title: data['title'],
      message: data['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => NotificationType.message,
      ),
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      eventId: data['eventId'],
      data: data['data'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.toString(),
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      if (eventId != null) 'eventId': eventId,
      if (data != null) 'data': data,
    };
  }
} 