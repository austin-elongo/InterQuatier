import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/models/notification.dart';
import 'package:interquatier/providers/notification_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: notifications.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Text('No notifications'),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationTile(notification: notification);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final AppNotification notification;

  const _NotificationTile({
    required this.notification,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: _getNotificationIcon(),
      title: Text(notification.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.message),
          Text(
            timeago.format(notification.createdAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      trailing: notification.isRead
          ? null
          : Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
      onTap: () async {
        if (!notification.isRead) {
          await NotificationService().markAsRead(notification.id);
        }
        if (notification.eventId != null && context.mounted) {
          // Navigate to event details
          // TODO: Implement navigation
        }
      },
    );
  }

  Widget _getNotificationIcon() {
    IconData iconData;
    Color? color;

    switch (notification.type) {
      case NotificationType.eventInvite:
        iconData = Icons.mail;
        color = Colors.blue;
        break;
      case NotificationType.eventJoined:
        iconData = Icons.group_add;
        color = Colors.green;
        break;
      case NotificationType.eventCancelled:
        iconData = Icons.event_busy;
        color = Colors.red;
        break;
      case NotificationType.eventReminder:
        iconData = Icons.alarm;
        color = Colors.orange;
        break;
      case NotificationType.eventUpdated:
        iconData = Icons.update;
        color = Colors.purple;
        break;
      case NotificationType.message:
        iconData = Icons.message;
        color = Colors.blue;
        break;
    }

    return CircleAvatar(
      backgroundColor: color?.withOpacity(0.2),
      child: Icon(iconData, color: color),
    );
  }
} 