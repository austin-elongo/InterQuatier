import 'package:flutter/material.dart';
import 'package:interquatier/widgets/event_category_card.dart';
import 'package:interquatier/constants/event_categories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/providers/event_provider.dart';
import 'package:interquatier/widgets/quick_actions_bar.dart';

class EventsMenuScreen extends StatelessWidget {
  const EventsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('Building EventsMenuScreen');
    return Consumer(
      builder: (context, ref, child) {
        try {
          final eventState = ref.watch(eventStateProvider);
          debugPrint('EventState: $eventState');
          
          return Scaffold(
            appBar: AppBar(
              title: const Text('Events'),
            ),
            body: Column(
              children: [
                const QuickActionsBar(),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    itemCount: eventCategories.length,
                    itemBuilder: (context, index) {
                      final category = eventCategories[index];
                      return EventCategoryCard(
                        title: category.title,
                        icon: category.icon,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/events/${category.route}',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _navigateToCreateEvent(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Event'),
            ),
          );
        } catch (e) {
          debugPrint('Error in EventsMenuScreen: $e');
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  void _navigateToCreateEvent(BuildContext context) {
    Navigator.pushNamed(context, '/create-event');
  }
} 