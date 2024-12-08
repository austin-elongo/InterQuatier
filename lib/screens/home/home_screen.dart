import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/providers/event_provider.dart';
import 'package:interquatier/providers/event_state.dart';
import 'package:interquatier/models/event.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:interquatier/screens/events/event_details_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventState = ref.watch(eventStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('InterQuatier'),
      ),
      body: Builder(
        builder: (context) {
          if (eventState is EventLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (eventState is EventError) {
            final errorState = eventState as EventError;
            return Center(child: Text('Error: ${errorState.message}'));
          }
          
          if (eventState is EventSuccess) {
            final successState = eventState as EventSuccess;
            return _buildEventsList(context, successState.events);
          }
          
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildEventsList(BuildContext context, List<Event> events) {
    if (events.isEmpty) {
      return const Center(child: Text('No events found'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Featured Event
        if (events.isNotEmpty) _buildFeaturedEvent(context, events.first),
        
        const SizedBox(height: 24),
        
        // Upcoming Events
        Text(
          'Upcoming Events',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        
        // Events Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: events.length - 1,
          itemBuilder: (context, index) {
            final event = events[index + 1];
            return _buildEventCard(context, event);
          },
        ),
      ],
    );
  }

  Widget _buildFeaturedEvent(BuildContext context, Event event) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailsScreen(event: event),
        ),
      ),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: CachedNetworkImageProvider(event.bannerImageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.8),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                event.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Event event) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailsScreen(event: event),
        ),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: event.bannerImageUrl,
                fit: BoxFit.cover,
              ),
            ),
            
            // Event Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 