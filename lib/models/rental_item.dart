import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:interquatier/models/rental_booking.dart';

enum RentalCategory {
  sports,
  party,
  camping,
  gaming,
  other,
}

class RentalItem {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final List<String> images;
  final double pricePerDay;
  final RentalCategory category;
  final String condition;
  final bool isAvailable;
  final Map<String, dynamic> specifications;
  final DateTime createdAt;
  final List<String> tags;
  final int quantity;
  final String location;
  final List<String> eventTypes;
  final List<String> suitableForEvents;
  final List<RentalBooking> bookings;
  final RentalAvailability availability;

  RentalItem({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.images,
    required this.pricePerDay,
    required this.category,
    required this.condition,
    this.isAvailable = true,
    required this.specifications,
    required this.createdAt,
    required this.tags,
    required this.quantity,
    required this.location,
    required this.eventTypes,
    required this.suitableForEvents,
    required this.bookings,
    required this.availability,
  });

  factory RentalItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RentalItem(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      pricePerDay: (data['pricePerDay'] ?? 0.0).toDouble(),
      category: RentalCategory.values.firstWhere(
        (e) => e.toString() == data['category'],
        orElse: () => RentalCategory.other,
      ),
      condition: data['condition'] ?? 'Used',
      isAvailable: data['isAvailable'] ?? true,
      specifications: Map<String, dynamic>.from(data['specifications'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      tags: List<String>.from(data['tags'] ?? []),
      quantity: data['quantity'] ?? 1,
      location: data['location'] ?? '',
      eventTypes: List<String>.from(data['eventTypes'] ?? []),
      suitableForEvents: List<String>.from(data['suitableForEvents'] ?? []),
      bookings: List<RentalBooking>.from(data['bookings'] ?? []),
      availability: RentalAvailability.fromMap(data['availability'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'images': images,
      'pricePerDay': pricePerDay,
      'category': category.toString(),
      'condition': condition,
      'isAvailable': isAvailable,
      'specifications': specifications,
      'createdAt': Timestamp.fromDate(createdAt),
      'tags': tags,
      'quantity': quantity,
      'location': location,
      'eventTypes': eventTypes,
      'suitableForEvents': suitableForEvents,
      'bookings': bookings,
      'availability': availability.toMap(),
    };
  }
}

class RentalAvailability {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<DateTime> unavailableDates;
  final bool isAvailable;

  const RentalAvailability({
    this.startDate,
    this.endDate,
    this.unavailableDates = const [],
    this.isAvailable = true,
  });

  factory RentalAvailability.fromMap(Map<String, dynamic> data) {
    return RentalAvailability(
      startDate: data['startDate'] != null 
          ? (data['startDate'] as Timestamp).toDate()
          : null,
      endDate: data['endDate'] != null 
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      unavailableDates: (data['unavailableDates'] as List<dynamic>?)
          ?.map((date) => (date as Timestamp).toDate())
          .toList() ?? [],
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'unavailableDates': unavailableDates.map((date) => Timestamp.fromDate(date)).toList(),
      'isAvailable': isAvailable,
    };
  }
} 