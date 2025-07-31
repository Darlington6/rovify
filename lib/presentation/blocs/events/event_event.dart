part of 'event_bloc.dart';

abstract class EventEvent {
  const EventEvent();
}

class LoadUpcomingEvents extends EventEvent {}

class ToggleFavoriteEvent extends EventEvent {
  final String eventId;
  final bool isFavorite;

  const ToggleFavoriteEvent(this.eventId, this.isFavorite);
}