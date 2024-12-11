import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  confirmed,
  active,
  completed,
  cancelled,
}

class RentalBooking {
  final String id;
  final String itemId;
  final String ownerId;
  final String renterId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final BookingStatus status;
  final DateTime createdAt;
  final String eventId;
  final int quantity;

  const RentalBooking({
    required this.id,
    required this.itemId,
    required this.ownerId,
    required this.renterId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.eventId,
    required this.quantity,
  });

  factory RentalBooking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RentalBooking(
      id: doc.id,
      itemId: data['itemId'],
      ownerId: data['ownerId'],
      renterId: data['renterId'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      totalPrice: (data['totalPrice'] as num).toDouble(),
      status: BookingStatus.values.byName(data['status']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      eventId: data['eventId'],
      quantity: data['quantity'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'itemId': itemId,
      'ownerId': ownerId,
      'renterId': renterId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'totalPrice': totalPrice,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'eventId': eventId,
      'quantity': quantity,
    };
  }
} 