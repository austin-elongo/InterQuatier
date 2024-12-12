import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/providers/relationship_privacy_provider.dart';

class ProfilePrivacySection extends ConsumerWidget {
  final String userId;

  const ProfilePrivacySection({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final privacyAsync = ref.watch(relationshipPrivacyProvider);

    return privacyAsync.when(
      data: (settings) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Text('Privacy Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(
              context,
              '/relationships/privacy',
            ),
          ),
          if (settings.showInProfile) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Overview',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildPrivacyInfo(
                    context,
                    'Default Privacy',
                    settings.defaultPrivacy.name.toUpperCase(),
                    Icons.visibility,
                  ),
                  if (settings.allowInvites)
                    _buildPrivacyInfo(
                      context,
                      'Accepting Invites',
                      'Yes',
                      Icons.person_add,
                    ),
                  _buildPrivacyInfo(
                    context,
                    'Event Notifications',
                    settings.notifyNewEvents ? 'On' : 'Off',
                    Icons.notifications,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildPrivacyInfo(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 