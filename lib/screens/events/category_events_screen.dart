import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/models/event.dart';
import 'package:interquatier/providers/event_provider.dart';
import 'package:interquatier/widgets/events/event_card.dart';

class CategoryEventsScreen extends ConsumerWidget {
  final String category;

  const CategoryEventsScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(allAccessibleEventsProvider(category));
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text('$category Events'),
      ),
      body: eventsAsync.when(
        data: (events) {
          final categoryEvents = events
              .where((event) => event.sport == category)
              .toList();

          if (categoryEvents.isEmpty) {
            return _buildEmptyState(context);
          }

          // Split events into upcoming and past
          final upcomingEvents = categoryEvents
              .where((event) => event.startTime.isAfter(now))
              .toList()
            ..sort((a, b) => a.startTime.compareTo(b.startTime));

          final pastEvents = categoryEvents
              .where((event) => event.startTime.isBefore(now))
              .toList()
            ..sort((a, b) => b.startTime.compareTo(a.startTime));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (upcomingEvents.isNotEmpty) ...[
                Text(
                  'Upcoming Events',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildEventsGrid(upcomingEvents),
                const SizedBox(height: 32),
              ],
              if (pastEvents.isNotEmpty) ...[
                Text(
                  'Past Events',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildEventsGrid(pastEvents),
              ],
              if (upcomingEvents.isEmpty && pastEvents.isEmpty)
                _buildEmptyState(context),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No $category Events Yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to create a $category event!',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/create-event');
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Event'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsGrid(List<Event> events) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return EventCard(event: events[index]);
      },
    );
  }
} 