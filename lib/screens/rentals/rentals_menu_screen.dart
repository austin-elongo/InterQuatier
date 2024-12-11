import 'package:flutter/material.dart';
import 'package:interquatier/models/rental_item.dart';
import 'package:interquatier/widgets/event_category_card.dart';

class RentalsMenuScreen extends StatelessWidget {
  const RentalsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental Equipment'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: RentalCategory.values.map((category) {
          return EventCategoryCard(
            title: _getCategoryTitle(category),
            icon: _getCategoryIcon(category),
            onTap: () => _navigateToCategory(context, category),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateRental(context),
        label: const Text('List Equipment'),
        icon: const Icon(Icons.add),
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
        return Icons.sports_baseball_rounded;
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

  void _navigateToCategory(BuildContext context, RentalCategory category) {
    Navigator.pushNamed(
      context,
      '/rentals/${category.toString().split('.').last}',
    );
  }

  void _navigateToCreateRental(BuildContext context) {
    Navigator.pushNamed(context, '/create-rental');
  }
} 