import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/models/event.dart';
import 'package:interquatier/models/rental_item.dart';
import 'package:interquatier/providers/rental_provider.dart';

class RequiredEquipmentSection extends ConsumerWidget {
  final Event event;

  const RequiredEquipmentSection({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Required Equipment',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: event.requiredEquipment.length,
          itemBuilder: (context, index) {
            final equipment = event.requiredEquipment[index];
            return _EquipmentItem(
              equipment: equipment,
              eventId: event.id,
              eventDate: event.startTime,
            );
          },
        ),
      ],
    );
  }
}

class _EquipmentItem extends ConsumerWidget {
  final RequiredEquipment equipment;
  final String eventId;
  final DateTime eventDate;

  const _EquipmentItem({
    required this.equipment,
    required this.eventId,
    required this.eventDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestedRentalsAsync = ref.watch(
      suggestedRentalsProvider((
        equipmentName: equipment.name,
        eventDate: eventDate,
      )),
    );

    return ExpansionTile(
      title: Row(
        children: [
          Text(equipment.name),
          if (equipment.isCompulsory)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Required',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onError,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
      subtitle: equipment.description != null
          ? Text(equipment.description!)
          : null,
      children: [
        suggestedRentalsAsync.when(
          data: (rentals) => Column(
            children: [
              if (rentals.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No rental items available'),
                )
              else
                ...rentals.map((rental) => ListTile(
                      leading: rental.images.isNotEmpty
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(rental.images.first),
                            )
                          : null,
                      title: Text(rental.title),
                      subtitle: Text('${rental.pricePerDay}/day'),
                      trailing: FilledButton(
                        onPressed: () => _rentItem(context, rental),
                        child: const Text('Rent'),
                      ),
                    )),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ],
    );
  }

  void _rentItem(BuildContext context, RentalItem item) {
    // Navigate to rental booking screen
    Navigator.pushNamed(
      context,
      '/rentals/book',
      arguments: {
        'item': item,
        'eventId': eventId,
        'eventDate': eventDate,
      },
    );
  }
} 