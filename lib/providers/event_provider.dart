import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/models/event.dart';
import 'package:interquatier/providers/event_state.dart';
import 'package:flutter/foundation.dart';
import 'package:interquatier/providers/relationship_provider.dart';
import 'dart:async';

final eventStateProvider = StateNotifierProvider<EventNotifier, EventState>((ref) {
  return EventNotifier();
});

class EventNotifier extends StateNotifier<EventState> {
  final _firestore = FirebaseFirestore.instance;
  
  EventNotifier() : super(const EventInitial()) {
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      state = const EventLoading();
      
      await checkPastEvents();
      
      final snapshot = await _firestore
          .collection('events')
          .orderBy('dateTime', descending: false)
          .get();
          
      final events = snapshot.docs
          .map((doc) => Event.fromFirestore(doc))
          .toList();
          
      state = EventSuccess(events);
    } catch (e) {
      state = EventError(e.toString());
    }
  }

  Future<void> createEvent(Event event) async {
    try {
      state = const EventLoading();
      await _firestore.collection('events').add(event.toFirestore());
      await loadEvents();
    } catch (e) {
      state = EventError(e.toString());
    }
  }

  Future<void> updateEvent(Event event) async {
    try {
      state = const EventLoading();
      await _firestore
          .collection('events')
          .doc(event.id)
          .update(event.toFirestore());
      await loadEvents();
    } catch (e) {
      state = EventError(e.toString());
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      state = const EventLoading();
      await _firestore.collection('events').doc(eventId).delete();
      await loadEvents();
    } catch (e) {
      state = EventError(e.toString());
    }
  }

  Future<void> joinEvent(String eventId, String userId) async {
    try {
      state = const EventLoading();
      await _firestore.collection('events').doc(eventId).update({
        'currentParticipants': FieldValue.arrayUnion([userId]),
      });
      await loadEvents();
    } catch (e) {
      state = EventError(e.toString());
    }
  }

  Future<void> leaveEvent(String eventId, String userId) async {
    try {
      state = const EventLoading();
      await _firestore.collection('events').doc(eventId).update({
        'currentParticipants': FieldValue.arrayRemove([userId]),
      });
      await loadEvents();
    } catch (e) {
      state = EventError(e.toString());
    }
  }

  Future<void> checkPastEvents() async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('events')
          .where('dateTime', isLessThan: now)
          .get();

      for (var doc in snapshot.docs) {
        final event = Event.fromFirestore(doc);
        
        // Update creator's past events
        await _firestore.collection('users').doc(event.creatorId).update({
          'pastEvents': FieldValue.arrayUnion([event.id])
        });

        // Update participants' past events
        for (var userId in event.currentParticipants) {
          await _firestore.collection('users').doc(userId).update({
            'pastEvents': FieldValue.arrayUnion([event.id])
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking past events: $e');
    }
  }
}

// Add these providers to filter events
final publicEventsProvider = StreamProvider.autoDispose<List<Event>>((ref) {
  return FirebaseFirestore.instance
      .collection('events')
      .where('visibility', isEqualTo: EventVisibility.public.index)
      .orderBy('dateTime', descending: true)
      .snapshots()
      .map((snapshot) => 
          snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
});

final relationshipEventsProvider = StreamProvider.autoDispose.family<List<Event>, String>((ref, userId) {
  final relationshipsStream = ref.watch(confirmedRelationshipsProvider(userId));
  
  return relationshipsStream.when(
    data: (relationships) {
      final relatedUserIds = relationships.map((r) => 
        r.fromUserId == userId ? r.toUserId : r.fromUserId
      ).toList();

      return FirebaseFirestore.instance
          .collection('events')
          .where('creatorId', whereIn: relatedUserIds)
          .where('visibility', isEqualTo: EventVisibility.relationships.index)
          .orderBy('startTime', descending: true)
          .snapshots()
          .map((snapshot) => 
              snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

// Combined events stream
final allAccessibleEventsProvider = StreamProvider.autoDispose.family<List<Event>, String>((ref, userId) {
  final publicEvents = ref.watch(publicEventsProvider);
  final relationshipEvents = ref.watch(relationshipEventsProvider(userId));

  return publicEvents.when(
    data: (public) => relationshipEvents.when(
      data: (relationships) => Stream.value([...public, ...relationships]
        ..sort((a, b) => b.startTime.compareTo(a.startTime))),
      loading: () => Stream.value(public),
      error: (_, __) => Stream.value(public),
    ),
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
}); 