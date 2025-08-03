import 'package:equatable/equatable.dart';
import 'package:rovify/domain/entities/event.dart';

enum EventStatus { initial, loading, success, failure }

class EventState extends Equatable {
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

  @override
  List<Object> get props => [];
}

class EventInitial extends EventState {}

class EventCreating extends EventState {}

class EventCreatedSuccessfully extends EventState {}

class EventLoading extends EventState {} // Added

class EventLoaded extends EventState {
  const EventLoaded(List<Event> events) : super(events: events);

  @override
  List<Object> get props => [events];
}

class EventError extends EventState {
  final String message;

  const EventError(this.message);

  @override
  List<Object> get props => [message];
}