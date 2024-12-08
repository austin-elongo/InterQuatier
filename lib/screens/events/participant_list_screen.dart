import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/models/event.dart';

class ParticipantListScreen extends ConsumerWidget {
  final Event event;

  const ParticipantListScreen({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participants'),
      ),
      body: Column(
        children: [
          // Progress Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '${event.currentParticipants.length}/${event.participantLimit}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: event.currentParticipants.length / event.participantLimit,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getAvailabilityText(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          // Participants List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: event.currentParticipants.length,
              itemBuilder: (context, index) {
                final userId = event.currentParticipants[index];
                return _buildParticipantTile(context, userId);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getAvailabilityText() {
    final spotsLeft = event.participantLimit - event.currentParticipants.length;
    if (spotsLeft == 0) {
      return 'Event is full';
    } else {
      return '$spotsLeft ${spotsLeft == 1 ? 'spot' : 'spots'} left';
    }
  }

  Widget _buildParticipantTile(BuildContext context, String userId) {
    // TODO: Replace with actual user data from Firebase
    return ListTile(
      leading: CircleAvatar(
        child: Text(userId[0].toUpperCase()),
      ),
      title: Text('User $userId'),
      subtitle: Text('Joined ${DateTime.now().difference(event.createdAt).inDays} days ago'),
    );
  }
} 