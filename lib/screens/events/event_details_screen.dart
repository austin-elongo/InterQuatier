import 'package:flutter/material.dart';
import 'package:interquatier/models/event.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/screens/events/participant_list_screen.dart';
import 'package:interquatier/providers/auth_provider.dart';
import 'package:interquatier/providers/event_provider.dart';

class EventDetailsScreen extends ConsumerWidget {
  final Event event;

  const EventDetailsScreen({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final isJoined = event.currentParticipants.contains(user?.uid);

    final surfaceColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsing App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: event.bannerImageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: surfaceColor,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: surfaceColor,
                  child: const Icon(Icons.sports, size: 64),
                ),
              ),
            ),
          ),

          // Event Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      _buildStatusChip(context, event.status),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Key Info Cards
                  _buildInfoSection(context),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(event.description),
                  const SizedBox(height: 24),

                  // Additional Details
                  _buildDetailsSection(context),
                  const SizedBox(height: 24),

                  // Participants
                  _buildParticipantsSection(context),
                  const SizedBox(height: 32),

                  // Join Button
                  _buildJoinButton(context, ref),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handleJoinEvent(context, ref),
        icon: Icon(isJoined ? Icons.check : Icons.add),
        label: Text(isJoined ? 'Joined' : 'Join Event'),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(context, status),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'full':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Widget _buildInfoSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            context,
            Icons.calendar_today,
            'Date',
            DateFormat('MMM dd, yyyy').format(event.dateTime),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
            context,
            Icons.access_time,
            'Time',
            DateFormat('HH:mm').format(event.dateTime),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
            context,
            Icons.euro,
            'Entry Fee',
            event.entryFee > 0 ? '€${event.entryFee}' : 'Free',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Details',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildDetailRow(context, Icons.sports, 'Sport', event.sport),
        _buildDetailRow(
          context,
          Icons.location_on,
          'Location',
          event.location,
        ),
        _buildDetailRow(
          context,
          Icons.group,
          'Skill Level',
          event.skillLevel,
        ),
        if (event.equipmentProvided.isNotEmpty)
          _buildDetailRow(
            context,
            Icons.sports_tennis,
            'Equipment',
            event.equipmentProvided,
          ),
        _buildDetailRow(
          context,
          Icons.timer,
          'Duration',
          event.duration,
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection(BuildContext context) {
    return GestureDetector(
      onTap: () => _showParticipants(context),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Participants',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${event.currentParticipants.length}/${event.participantLimit} joined',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: event.currentParticipants.length / event.participantLimit,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinButton(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final isJoined = event.currentParticipants.contains(user?.uid);
    final isFull = event.currentParticipants.length >= event.participantLimit;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isFull && !isJoined ? null : () => _handleJoinEvent(context, ref),
        child: Text(isJoined ? 'Leave Event' : 'Join Event'),
      ),
    );
  }

  void _showParticipants(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParticipantListScreen(event: event),
      ),
    );
  }

  Future<void> _handleJoinEvent(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to join events')),
      );
      return;
    }

    try {
      final isJoined = event.currentParticipants.contains(user.uid);
      
      if (isJoined) {
        await ref.read(eventStateProvider.notifier).leaveEvent(event.id, user.uid);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Left the event')),
          );
        }
      } else {
        await ref.read(eventStateProvider.notifier).joinEvent(event.id, user.uid);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully joined the event')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
} 