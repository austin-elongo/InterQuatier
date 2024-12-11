import 'package:flutter/material.dart';
import 'package:interquatier/models/relationship_privacy_settings.dart';

class PrivacyIndicator extends StatelessWidget {
  final RelationshipPrivacy privacy;
  final bool mini;

  const PrivacyIndicator({
    super.key,
    required this.privacy,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    final icon = switch (privacy) {
      RelationshipPrivacy.public => Icons.public,
      RelationshipPrivacy.friends => Icons.group,
      RelationshipPrivacy.private => Icons.lock,
    };

    final label = switch (privacy) {
      RelationshipPrivacy.public => 'Public',
      RelationshipPrivacy.friends => 'Friends',
      RelationshipPrivacy.private => 'Private',
    };

    if (mini) {
      return Icon(
        icon,
        size: 16,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
} 