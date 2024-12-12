import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:interquatier/models/review.dart';

enum EventVisibility {
  public,
  relationships,  // Premium feature
}

class Event {
  final String id;
  final String creatorId;
  final String title;
  final String bannerImageUrl;
  final String sport;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String skillLevel;
  final int participantLimit;
  final List<String> currentParticipants;
  final String description;
  final String status;
  final DateTime createdAt;
  final String eventType;
  final double entryFee;
  final String equipmentProvided;
  final String ageGroup;
  final String duration;
  final String genderRestriction;
  final String weatherBackupPlan;
  final List<String> specialRequirements;
  final String venueType;
  final String additionalNotes;
  final EventVisibility visibility;
  final List<String> participants;
  final List<Review> reviews;
  final List<RequiredEquipment> requiredEquipment;

  Event({
    required this.id,
    required this.creatorId,
    required this.title,
    required this.bannerImageUrl,
    required this.sport,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.skillLevel,
    required this.participantLimit,
    required this.currentParticipants,
    required this.description,
    this.status = 'ACTIVE',
    required this.createdAt,
    required this.eventType,
    required this.entryFee,
    required this.equipmentProvided,
    required this.ageGroup,
    required this.duration,
    required this.genderRestriction,
    required this.weatherBackupPlan,
    required this.specialRequirements,
    required this.venueType,
    required this.additionalNotes,
    this.visibility = EventVisibility.public,
    this.participants = const [],
    this.reviews = const [],
    this.requiredEquipment = const [],
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      creatorId: data['creatorId'] ?? '',
      title: data['title'] ?? '',
      bannerImageUrl: data['bannerImageUrl'] ?? '',
      sport: data['sport'] ?? '',
      location: data['location'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      skillLevel: data['skillLevel'] ?? '',
      participantLimit: data['participantLimit'] ?? 0,
      currentParticipants: List<String>.from(data['currentParticipants'] ?? []),
      description: data['description'] ?? '',
      status: data['status'] ?? 'ACTIVE',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      eventType: data['eventType'] ?? '',
      entryFee: (data['entryFee'] ?? 0).toDouble(),
      equipmentProvided: data['equipmentProvided'] ?? '',
      ageGroup: data['ageGroup'] ?? '',
      duration: data['duration'] ?? '',
      genderRestriction: data['genderRestriction'] ?? '',
      weatherBackupPlan: data['weatherBackupPlan'] ?? '',
      specialRequirements: List<String>.from(data['specialRequirements'] ?? []),
      venueType: data['venueType'] ?? '',
      additionalNotes: data['additionalNotes'] ?? '',
      visibility: EventVisibility.values[data['visibility'] ?? 0],
      participants: List<String>.from(data['participants'] ?? []),
      reviews: (data['reviews'] as List<dynamic>?)?.map((review) => 
          Review.fromMap(review as Map<String, dynamic>)).toList() ?? [],
      requiredEquipment: (data['requiredEquipment'] as List<dynamic>?)
          ?.map((e) => RequiredEquipment.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'creatorId': creatorId,
      'title': title,
      'bannerImageUrl': bannerImageUrl,
      'sport': sport,
      'location': location,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'skillLevel': skillLevel,
      'participantLimit': participantLimit,
      'currentParticipants': currentParticipants,
      'description': description,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'eventType': eventType,
      'entryFee': entryFee,
      'equipmentProvided': equipmentProvided,
      'ageGroup': ageGroup,
      'duration': duration,
      'genderRestriction': genderRestriction,
      'weatherBackupPlan': weatherBackupPlan,
      'specialRequirements': specialRequirements,
      'venueType': venueType,
      'additionalNotes': additionalNotes,
      'visibility': visibility.index,
      'participants': participants,
      'reviews': reviews.map((review) => review.toMap()).toList(),
      'requiredEquipment': requiredEquipment.map((e) => e.toMap()).toList(),
    };
  }
}

class RequiredEquipment {
  final String name;
  final bool isCompulsory;
  final String? description;

  const RequiredEquipment({
    required this.name,
    required this.isCompulsory,
    this.description,
  });

  factory RequiredEquipment.fromMap(Map<String, dynamic> data) {
    return RequiredEquipment(
      name: data['name'],
      isCompulsory: data['isCompulsory'],
      description: data['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isCompulsory': isCompulsory,
      'description': description,
    };
  }
} 