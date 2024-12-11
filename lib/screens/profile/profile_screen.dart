import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/providers/auth_provider.dart';
import 'package:interquatier/providers/user_provider.dart';
import 'package:interquatier/providers/user_events_provider.dart';
import 'package:interquatier/widgets/profile/profile_privacy_section.dart';
import 'package:interquatier/widgets/profile/notification_settings_tile.dart';
import 'package:interquatier/widgets/reviews/audio_player.dart';
import 'package:interquatier/widgets/profile/relationship_badges_section.dart';
import 'package:interquatier/widgets/profile/profile_drawer.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    if (user == null) {
      return const Center(child: Text('Please sign in to view your profile'));
    }

    final userProfileAsync = ref.watch(userProfileProvider(user.uid));

    return userProfileAsync.when(
      data: (profile) => Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Profile'),
              Tab(text: 'Past Events'),
              Tab(text: 'Hosted Events'),
            ],
          ),
        ),
        endDrawer: const ProfileDrawer(),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Profile Tab
            ListView(
              children: [
                // Profile Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: profile.photoUrl != null
                            ? NetworkImage(profile.photoUrl!)
                            : null,
                        child: profile.photoUrl == null
                            ? Text(
                                profile.displayName[0].toUpperCase(),
                                style: Theme.of(context).textTheme.headlineMedium,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.displayName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.email,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // Relationship Badges Section
                RelationshipBadgesSection(userId: user.uid),
                const Divider(),

                // Privacy Section
                ProfilePrivacySection(userId: user.uid),
                const Divider(),

                // Notification Settings
                const NotificationSettingsTile(),
                const Divider(),

                // Account Actions
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Profile'),
                  onTap: () => Navigator.pushNamed(context, '/profile/edit'),
                ),
                ListTile(
                  leading: const Icon(Icons.star),
                  title: const Text('Premium Features'),
                  onTap: () => Navigator.pushNamed(context, '/premium'),
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Sign Out'),
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),

            // Past Events Tab
            _buildPastEventsTab(user.uid),

            // Hosted Events Tab
            _buildHostedEventsTab(user.uid),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildPastEventsTab(String userId) {
    return Consumer(
      builder: (context, ref, child) {
        final pastEventsAsync = ref.watch(userPastEventsProvider(userId));
        return pastEventsAsync.when(
          data: (events) => ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ExpansionTile(
                title: Text(event.title),
                subtitle: Text(event.startTime.toString()),
                children: [
                  if (event.reviews.isNotEmpty)
                    ...event.reviews.map((review) {
                      if (review.audioUrl?.isNotEmpty ?? false) {
                        return AudioPlayer(
                          audioUrl: review.audioUrl!,
                          onError: (error) => ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(error))),
                        );
                      }
                      return ListTile(
                        title: Text(review.text ?? ''),
                        subtitle: Text(review.createdAt.toString()),
                      );
                    }),
                ],
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        );
      },
    );
  }

  Widget _buildHostedEventsTab(String userId) {
    return Consumer(
      builder: (context, ref, child) {
        final hostedEventsAsync = ref.watch(userHostedEventsProvider(userId));
        return hostedEventsAsync.when(
          data: (events) => ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                leading: event.bannerImageUrl != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(event.bannerImageUrl!),
                      )
                    : null,
                title: Text(event.title),
                subtitle: Text(event.startTime.toString()),
                trailing: Text('${event.participants.length} participants'),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/events/details',
                  arguments: event.id,
                ),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        );
      },
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldLogout ?? false && context.mounted) {
      await ref.read(authProvider.notifier).signOut();
    }
  }
} 