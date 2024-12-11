import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/models/relationship.dart';
import 'package:interquatier/models/relationship_badge.dart';
import 'package:interquatier/providers/relationship_provider.dart';
import 'package:interquatier/providers/relationship_privacy_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:interquatier/widgets/relationships/privacy_indicator.dart';

class RelationshipListItem extends ConsumerWidget {
  final Relationship relationship;

  const RelationshipListItem({
    super.key,
    required this.relationship,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final privacySettings = ref.watch(relationshipPrivacyProvider);

    return privacySettings.when(
      data: (settings) => ListTile(
        leading: CircleAvatar(
          backgroundImage: relationship.user.photoUrl != null
              ? NetworkImage(relationship.user.photoUrl!)
              : null,
          child: relationship.user.photoUrl == null
              ? Text(relationship.user.displayName[0].toUpperCase())
              : null,
        ),
        title: Text(relationship.user.displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              relationship.isReceiver
                  ? 'Wants to be your ${relationship.badge.badgeType}'
                  : 'Your ${relationship.badge.badgeType}',
            ),
            Row(
              children: [
                PrivacyIndicator(
                  privacy: settings.specificSettings[relationship.id] ?? 
                          settings.defaultPrivacy,
                  mini: true,
                ),
                const SizedBox(width: 4),
                Text(
                  timeago.format(relationship.badge.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrivacyIndicator(
              privacy: settings.specificSettings[relationship.id] ?? 
                      settings.defaultPrivacy,
              mini: true,
            ),
            const SizedBox(width: 4),
            _buildActionButton(context, ref, relationship.isReceiver),
          ],
        ),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Icon(Icons.error),
    );
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref, bool isReceiver) {
    if (relationship.badge.status == BadgeStatus.pending && isReceiver) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => _respondToBadge(context, ref, true),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _respondToBadge(context, ref, false),
          ),
        ],
      );
    }

    return _buildStatusChip(context);
  }

  Widget _buildStatusChip(BuildContext context) {
    switch (relationship.badge.status) {
      case BadgeStatus.accepted:
        return Chip(
          label: const Text('Confirmed'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        );
      case BadgeStatus.rejected:
        return Chip(
          label: const Text('Rejected'),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        );
      case BadgeStatus.pending:
        return Chip(
          label: const Text('Pending'),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        );
      default:
        return const SizedBox();
    }
  }

  Future<void> _respondToBadge(
    BuildContext context,
    WidgetRef ref,
    bool accept,
  ) async {
    try {
      await ref.read(relationshipProvider.notifier).respondToBadge(
            relationship.badge.id,
            accept,
          );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
} 