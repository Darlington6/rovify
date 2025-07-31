part of 'event_bloc.dart';

enum EventStatus { initial, loading, success, failure }

class EventState {
  final EventStatus status;
  final List<Event> events;
  final String? errorMessage;
  final Set<String> favoriteEventIds;

  const EventState({
    this.status = EventStatus.initial,
    this.events = const [],
    this.errorMessage,
    this.favoriteEventIds = const {},
  });

  EventState copyWith({
    EventStatus? status,
    List<Event>? events,
    String? errorMessage,
    Set<String>? favoriteEventIds,
  }) {
    return EventState(
      status: status ?? this.status,
      events: events ?? this.events,
      errorMessage: errorMessage ?? this.errorMessage,
      favoriteEventIds: favoriteEventIds ?? this.favoriteEventIds,
    );
  }
}