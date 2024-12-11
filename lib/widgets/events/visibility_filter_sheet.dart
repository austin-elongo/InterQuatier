import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/models/event.dart';

final eventVisibilityFilterProvider = StateProvider<Set<EventVisibility>>((ref) {
  return {EventVisibility.public, EventVisibility.relationships};
});

class VisibilityFilterSheet extends ConsumerWidget {
  const VisibilityFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilters = ref.watch(eventVisibilityFilterProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Visibility',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Public Events'),
            value: selectedFilters.contains(EventVisibility.public),
            onChanged: (value) {
              final filters = Set<EventVisibility>.from(selectedFilters);
              if (value ?? false) {
                filters.add(EventVisibility.public);
              } else {
                filters.remove(EventVisibility.public);
              }
              ref.read(eventVisibilityFilterProvider.notifier).state = filters;
            },
          ),
          CheckboxListTile(
            title: const Text('Relationship Events'),
            value: selectedFilters.contains(EventVisibility.relationships),
            onChanged: (value) {
              final filters = Set<EventVisibility>.from(selectedFilters);
              if (value ?? false) {
                filters.add(EventVisibility.relationships);
              } else {
                filters.remove(EventVisibility.relationships);
              }
              ref.read(eventVisibilityFilterProvider.notifier).state = filters;
            },
          ),
        ],
      ),
    );
  }
} 