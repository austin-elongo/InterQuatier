import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/models/event.dart';
import 'package:interquatier/providers/event_state.dart';

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
} 