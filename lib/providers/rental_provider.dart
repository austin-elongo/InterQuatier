import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:interquatier/models/rental_item.dart';
import 'package:interquatier/models/rental_booking.dart';

final suggestedRentalsProvider = StreamProvider.autoDispose
    .family<List<RentalItem>, ({String equipmentName, DateTime eventDate})>(
  (ref, params) {
    return FirebaseFirestore.instance
        .collection('rental_items')
        .where('suitableForEvents', arrayContains: params.equipmentName)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RentalItem.fromFirestore(doc))
            .where((rental) => _isAvailableForDate(rental, params.eventDate))
            .toList());
  },
);

bool _isAvailableForDate(RentalItem rental, DateTime date) {
  if (!rental.availability.isAvailable) return false;
  
  // Check if date is within available range
  if (rental.availability.startDate != null &&
      date.isBefore(rental.availability.startDate!)) {
    return false;
  }
  if (rental.availability.endDate != null &&
      date.isAfter(rental.availability.endDate!)) {
    return false;
  }

  // Check if date is not in unavailable dates
  return !rental.availability.unavailableDates.contains(
    DateTime(date.year, date.month, date.day),
  );
}

final userRentalsProvider = StreamProvider.autoDispose.family<List<RentalItem>, String>(
  (ref, userId) {
    return FirebaseFirestore.instance
        .collection('rental_bookings')
        .where('renterId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
          final bookings = snapshot.docs;
          final rentalIds = bookings.map((doc) => doc.data()['rentalId'] as String).toSet();
          
          if (rentalIds.isEmpty) return [];

          final rentalsSnapshot = await FirebaseFirestore.instance
              .collection('rental_items')
              .where(FieldPath.documentId, whereIn: rentalIds.toList())
              .get();

          return rentalsSnapshot.docs
              .map((doc) => RentalItem.fromFirestore(doc))
              .toList();
        });
  },
);

final rentalBookingsProvider =
    StreamProvider.autoDispose.family<List<RentalBooking>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('rental_bookings')
      .where('renterId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => RentalBooking.fromFirestore(doc)).toList());
});

class RentalService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> createRentalItem(RentalItem item) async {
    await _firestore.collection('rental_items').add(item.toFirestore());
  }

  Future<void> createBooking(RentalBooking booking) async {
    await _firestore.collection('rental_bookings').add(booking.toFirestore());
  }

  Future<void> updateBookingStatus(
      String bookingId, BookingStatus status) async {
    await _firestore
        .collection('rental_bookings')
        .doc(bookingId)
        .update({'status': status.toString()});
  }

  Future<void> deleteRentalItem(String itemId) async {
    await _firestore.collection('rental_items').doc(itemId).delete();
  }
}

final rentalServiceProvider = Provider<RentalService>((ref) {
  return RentalService();
}); 