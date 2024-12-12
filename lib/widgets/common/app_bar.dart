import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/providers/notification_provider.dart';
import 'package:interquatier/widgets/common/notification_badge.dart';

class AppBarWithNotification extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? additionalActions;

  const AppBarWithNotification({
    super.key,
    required this.title,
    this.additionalActions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: unreadCount.when(
            data: (count) => NotificationBadge(
              count: count,
              child: const Icon(Icons.notifications),
            ),
            loading: () => const Icon(Icons.notifications),
            error: (_, __) => const Icon(Icons.notifications),
          ),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
        ),
        if (additionalActions != null) ...additionalActions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 