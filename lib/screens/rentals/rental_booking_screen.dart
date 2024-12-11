import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/models/rental_item.dart';
import 'package:interquatier/models/rental_booking.dart';
import 'package:interquatier/providers/auth_provider.dart';
import 'package:interquatier/providers/rental_provider.dart';
import 'package:intl/intl.dart';

class RentalBookingScreen extends ConsumerStatefulWidget {
  final RentalItem item;
  final String eventId;
  final DateTime eventDate;

  const RentalBookingScreen({
    super.key,
    required this.item,
    required this.eventId,
    required this.eventDate,
  });

  @override
  ConsumerState<RentalBookingScreen> createState() => _RentalBookingScreenState();
}

class _RentalBookingScreenState extends ConsumerState<RentalBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _startDate;
  late DateTime _endDate;
  int _quantity = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startDate = widget.eventDate;
    _endDate = widget.eventDate.add(const Duration(days: 1));
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.item.pricePerDay *
        _quantity *
        _endDate.difference(_startDate).inDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Equipment'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Item Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.item.images.isNotEmpty)
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          widget.item.images.first,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      widget.item.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${widget.item.pricePerDay}/day',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Booking Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Start Date'),
                              TextButton.icon(
                                icon: const Icon(Icons.calendar_today),
                                label: Text(
                                  DateFormat.yMMMd().format(_startDate),
                                ),
                                onPressed: () => _selectDate(true),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('End Date'),
                              TextButton.icon(
                                icon: const Icon(Icons.calendar_today),
                                label: Text(
                                  DateFormat.yMMMd().format(_endDate),
                                ),
                                onPressed: () => _selectDate(false),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Quantity'),
                        const SizedBox(width: 16),
                        SegmentedButton<int>(
                          segments: List.generate(
                            widget.item.quantity,
                            (index) => ButtonSegment<int>(
                              value: index + 1,
                              label: Text('${index + 1}'),
                            ),
                          ),
                          selected: {_quantity},
                          onSelectionChanged: (Set<int> newSelection) {
                            setState(() {
                              _quantity = newSelection.first;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '\$${totalPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isLoading ? null : _handleBooking,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Confirm Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: isStart ? widget.eventDate : _startDate,
      lastDate: widget.eventDate.add(const Duration(days: 30)),
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = date;
        }
      });
    }
  }

  Future<void> _handleBooking() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authProvider);
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to book equipment')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final booking = RentalBooking(
        id: '',
        itemId: widget.item.id,
        ownerId: widget.item.ownerId,
        renterId: user.uid,
        startDate: _startDate,
        endDate: _endDate,
        totalPrice: widget.item.pricePerDay *
            _quantity *
            _endDate.difference(_startDate).inDays,
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
        eventId: widget.eventId,
        quantity: _quantity,
      );

      await ref.read(rentalServiceProvider).createBooking(booking);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking request sent')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
} 