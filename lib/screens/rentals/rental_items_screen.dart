import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/models/rental_item.dart';
import 'package:interquatier/providers/rental_provider.dart';

class RentalItemsScreen extends ConsumerWidget {
  final RentalCategory category;

  const RentalItemsScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rentalsAsync = ref.watch(suggestedRentalsProvider((
      equipmentName: category.name,
      eventDate: DateTime.now(),
    )));

    return Scaffold(
      appBar: AppBar(
        title: Text(_getCategoryTitle(category)),
      ),
      body: rentalsAsync.when(
        data: (rentals) {
          if (rentals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No ${_getCategoryTitle(category)} Available',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to list equipment in this category!',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/rentals/create'),
                    icon: const Icon(Icons.add),
                    label: const Text('List Equipment'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rentals.length,
            itemBuilder: (context, index) {
              final rental = rentals[index];
              return Card(
                child: ListTile(
                  leading: rental.images.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(rental.images.first),
                        )
                      : null,
                  title: Text(rental.title),
                  subtitle: Text('${rental.pricePerDay}/day'),
                  trailing: rental.isAvailable
                      ? FilledButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/rentals/details',
                            arguments: rental,
                          ),
                          child: const Text('View'),
                        )
                      : const Chip(label: Text('Unavailable')),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  String _getCategoryTitle(RentalCategory category) {
    switch (category) {
      case RentalCategory.sports:
        return 'Sports Equipment';
      case RentalCategory.party:
        return 'Party Equipment';
      case RentalCategory.camping:
        return 'Camping Gear';
      case RentalCategory.gaming:
        return 'Gaming Equipment';
      case RentalCategory.other:
        return 'Other Equipment';
    }
  }

  IconData _getCategoryIcon(RentalCategory category) {
    switch (category) {
      case RentalCategory.sports:
        return Icons.sports_basketball_rounded;
      case RentalCategory.party:
        return Icons.celebration_rounded;
      case RentalCategory.camping:
        return Icons.landscape_rounded;
      case RentalCategory.gaming:
        return Icons.sports_esports_rounded;
      case RentalCategory.other:
        return Icons.category_rounded;
    }
  }
} 