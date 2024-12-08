import 'package:interquatier/models/event.dart';

abstract class EventState {
  const EventState();
}

class EventInitial extends EventState {
  const EventInitial();
}

class EventLoading extends EventState {
  const EventLoading();
}

class EventSuccess extends EventState {
  final List<Event> events;
  const EventSuccess(this.events);
}

class EventError extends EventState {
  final String message;
  const EventError(this.message);
} 