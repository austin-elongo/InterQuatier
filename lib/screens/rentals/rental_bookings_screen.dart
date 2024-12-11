import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/models/rental_booking.dart';
import 'package:interquatier/providers/rental_provider.dart';
import 'package:interquatier/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class RentalBookingsScreen extends ConsumerWidget {
  const RentalBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    if (user == null) return const SizedBox();

    final bookingsAsync = ref.watch(rentalBookingsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rentals'),
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return const Center(
              child: Text('No rental bookings yet'),
            );
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  title: Text('Booking #${booking.id.substring(0, 8)}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${DateFormat.yMMMd().format(booking.startDate)} - ${DateFormat.yMMMd().format(booking.endDate)}',
                      ),
                      Text('Quantity: ${booking.quantity}'),
                      Text('Total: \$${booking.totalPrice.toStringAsFixed(2)}'),
                    ],
                  ),
                  trailing: _buildStatusChip(context, booking.status),
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

  Widget _buildStatusChip(BuildContext context, BookingStatus status) {
    final colors = switch (status) {
      BookingStatus.pending => (
        background: Colors.orange.withOpacity(0.2),
        text: Colors.orange,
      ),
      BookingStatus.confirmed => (
        background: Colors.blue.withOpacity(0.2),
        text: Colors.blue,
      ),
      BookingStatus.active => (
        background: Colors.green.withOpacity(0.2),
        text: Colors.green,
      ),
      BookingStatus.completed => (
        background: Colors.grey.withOpacity(0.2),
        text: Colors.grey,
      ),
      BookingStatus.cancelled => (
        background: Colors.red.withOpacity(0.2),
        text: Colors.red,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: colors.text,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
} 