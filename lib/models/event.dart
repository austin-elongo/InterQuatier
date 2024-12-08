import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String creatorId;
  final String title;
  final String bannerImageUrl;
  final String sport;
  final String location;
  final DateTime dateTime;
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

  Event({
    required this.id,
    required this.creatorId,
    required this.title,
    required this.bannerImageUrl,
    required this.sport,
    required this.location,
    required this.dateTime,
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
      dateTime: (data['dateTime'] as Timestamp).toDate(),
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
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'creatorId': creatorId,
      'title': title,
      'bannerImageUrl': bannerImageUrl,
      'sport': sport,
      'location': location,
      'dateTime': Timestamp.fromDate(dateTime),
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
    };
  }
} 