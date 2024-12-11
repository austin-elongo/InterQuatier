import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/models/event.dart';
import 'package:interquatier/providers/notification_provider.dart';

class EventListItem extends ConsumerWidget {
  final Event event;

  const EventListItem({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUnread = ref.watch(eventNotificationsProvider(event.id)).when(
          data: (notifications) => notifications.any((n) => !n.isRead),
          loading: () => false,
          error: (_, __) => false,
        );

    return Stack(
      children: [
        Card(
          child: ListTile(
            title: Text(event.title),
            subtitle: Text(event.description),
            onTap: () => Navigator.pushNamed(
              context,
              '/event/${event.id}',
              arguments: event,
            ),
          ),
        ),
        if (hasUnread)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
} 