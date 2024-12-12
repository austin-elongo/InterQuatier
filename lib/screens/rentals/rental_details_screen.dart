import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/models/rental_item.dart';
import 'package:interquatier/models/rental_booking.dart';
import 'package:interquatier/providers/auth_provider.dart';
import 'package:interquatier/providers/rental_service_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:interquatier/widgets/rating/rating_display.dart';
import 'package:interquatier/widgets/rating/review_list.dart';
import 'package:interquatier/screens/reviews/reviews_screen.dart';

class RentalDetailsScreen extends ConsumerStatefulWidget {
  final RentalItem item;
  final String? eventId;

  const RentalDetailsScreen({
    super.key,
    required this.item,
    this.eventId,
  });

  @override
  ConsumerState<RentalDetailsScreen> createState() => _RentalDetailsScreenState();
}

class _RentalDetailsScreenState extends ConsumerState<RentalDetailsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  int _quantity = 1;
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _quantity = 1;
  }

  Future<void> _selectDateRange() async {
    final initialDateRange = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(days: 1)),
    );

    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      initialDateRange: initialDateRange,
    );

    if (pickedRange != null) {
      setState(() {
        _startDate = pickedRange.start;
        _endDate = pickedRange.end;
      });
    }
  }

  Future<void> _handleBooking() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select rental dates')),
      );
      return;
    }

    final user = ref.read(authProvider);
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to book items')),
        );
      }
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      final days = _endDate!.difference(_startDate!).inDays;
      final totalPrice = widget.item.pricePerDay * days * _quantity;

      final booking = RentalBooking(
        id: '',
        itemId: widget.item.id,
        ownerId: widget.item.ownerId,
        renterId: user.uid,
        startDate: _startDate!,
        endDate: _endDate!,
        totalPrice: totalPrice,
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
        eventId: widget.eventId ?? '',
        quantity: _quantity,
      );

      await ref.read(rentalServiceProvider).createBooking(booking);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking request sent!')),
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
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CarouselSlider(
                options: CarouselOptions(
                  height: 300,
                  viewportFraction: 1,
                  enableInfiniteScroll: false,
                ),
                items: widget.item.images.map((url) {
                  return CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                }).toList(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${currencyFormat.format(widget.item.pricePerDay)} per day',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(widget.item.description),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(widget.item.location),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: const Icon(Icons.inventory_2),
                    title: Text('${widget.item.quantity} available'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: const Icon(Icons.star),
                    title: Text(widget.item.condition),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Booking Details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      _startDate == null
                          ? 'Select dates'
                          : '${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}',
                    ),
                    trailing: TextButton(
                      onPressed: _selectDateRange,
                      child: const Text('Change'),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.numbers),
                    title: const Text('Quantity'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                          icon: const Icon(Icons.remove),
                        ),
                        Text('$_quantity'),
                        IconButton(
                          onPressed: _quantity < widget.item.quantity
                              ? () => setState(() => _quantity++)
                              : null,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                  if (_startDate != null && _endDate != null) ...[
                    const Divider(),
                    ListTile(
                      title: const Text('Total Price'),
                      trailing: Text(
                        currencyFormat.format(
                          widget.item.pricePerDay *
                              _endDate!.difference(_startDate!).inDays *
                              _quantity,
                        ),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reviews',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReviewsScreen(
                              targetId: widget.item.id,
                              targetType: 'rental',
                              title: widget.item.title,
                            ),
                          ),
                        ),
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  RatingDisplay(
                    targetId: widget.item.id,
                    targetType: 'rental',
                  ),
                  const SizedBox(height: 16),
                  ReviewList(
                    targetId: widget.item.id,
                    targetType: 'rental',
                    showHeader: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: FilledButton(
            onPressed: _isBooking ? null : _handleBooking,
            child: _isBooking
                ? const CircularProgressIndicator()
                : const Text('Book Now'),
          ),
        ),
      ),
    );
  }
} 