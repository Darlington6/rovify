import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:rovify/domain/entities/event.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object> get props => [];
}

class LoadUpcomingEvents extends EventEvent {}

class ToggleFavoriteEvent extends EventEvent {
  final String eventId;
  final bool isFavorite;

  const ToggleFavoriteEvent(this.eventId, this.isFavorite);
}

class CreateEventRequested extends EventEvent {
  final Event event;
  final File imageFile;

  const CreateEventRequested(this.event, this.imageFile);

  @override
  List<Object> get props => [event, imageFile];
}

class FetchEventsRequested extends EventEvent {}