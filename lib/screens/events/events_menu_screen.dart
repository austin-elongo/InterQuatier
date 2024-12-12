import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/providers/auth_provider.dart';
import 'package:interquatier/providers/event_provider.dart';
import 'package:interquatier/widgets/events/event_card.dart';
import 'package:interquatier/widgets/events/visibility_filter_sheet.dart';

class EventsMenuScreen extends ConsumerWidget {
  const EventsMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    if (user == null) return const SizedBox();

    final eventsAsync = ref.watch(allAccessibleEventsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showVisibilityFilter(context),
          ),
        ],
      ),
      body: eventsAsync.when(
        data: (events) => ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) => EventCard(event: events[index]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/events/create'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showVisibilityFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const VisibilityFilterSheet(),
    );
  }
} 