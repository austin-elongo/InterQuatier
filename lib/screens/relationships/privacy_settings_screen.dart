import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/providers/auth_provider.dart';
import 'package:interquatier/providers/relationship_privacy_provider.dart';
import 'package:interquatier/models/relationship_privacy_settings.dart';

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    if (user == null) return const SizedBox();

    final privacyAsync = ref.watch(relationshipPrivacyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
      ),
      body: privacyAsync.when(
        data: (settings) => ListView(
          children: [
            _buildDefaultPrivacySection(context, ref, settings),
            const Divider(),
            _buildProfileSection(context, ref, settings),
            const Divider(),
            _buildNotificationSection(context, ref, settings),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  void _updateSettings(WidgetRef ref, RelationshipPrivacySettings settings) {
    ref.read(relationshipPrivacyProvider.notifier).updateSettings(settings);
  }

  void _updateSpecificPrivacy(
    WidgetRef ref,
    String relationshipId,
    RelationshipPrivacy privacy,
  ) {
    ref.read(relationshipPrivacyProvider.notifier)
        .updatePrivacyForRelationship(relationshipId, privacy);
  }

  Widget _buildDefaultPrivacySection(
    BuildContext context,
    WidgetRef ref,
    RelationshipPrivacySettings settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Default Privacy',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        SegmentedButton<RelationshipPrivacy>(
          segments: RelationshipPrivacy.values.map((privacy) {
            return ButtonSegment<RelationshipPrivacy>(
              value: privacy,
              label: Text(privacy.name.toUpperCase()),
            );
          }).toList(),
          selected: {settings.defaultPrivacy},
          onSelectionChanged: (selected) {
            if (selected.isNotEmpty) {
              _updateSettings(
                ref,
                settings.copyWith(defaultPrivacy: selected.first),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    WidgetRef ref,
    RelationshipPrivacySettings settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Settings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Show Relationships in Profile'),
          value: settings.showInProfile,
          onChanged: (value) {
            _updateSettings(
              ref,
              settings.copyWith(showInProfile: value),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSection(
    BuildContext context,
    WidgetRef ref,
    RelationshipPrivacySettings settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notification Settings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Notify About New Events'),
          value: settings.notifyNewEvents,
          onChanged: (value) {
            _updateSettings(
              ref,
              settings.copyWith(notifyNewEvents: value),
            );
          },
        ),
        SwitchListTile(
          title: const Text('Allow Relationship Invites'),
          value: settings.allowInvites,
          onChanged: (value) {
            _updateSettings(
              ref,
              settings.copyWith(allowInvites: value),
            );
          },
        ),
      ],
    );
  }
} 