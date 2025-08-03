import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rovify/domain/entities/event.dart';
import 'package:rovify/domain/usecases/create_event.dart';
import 'package:rovify/domain/usecases/fetch_events.dart';
import 'package:rovify/domain/usecases/get_upcoming_events.dart';
import 'package:rovify/domain/usecases/toggle_event_favorite.dart';
import 'package:rovify/presentation/blocs/event/event_event.dart';
import 'package:rovify/presentation/blocs/event/event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final CreateEvent createEventUseCase;
  final FetchEvents fetchEventsUseCase;
  final GetUpcomingEvents getUpcomingEvents;
  final ToggleEventFavorite toggleEventFavorite;
  final String userId;

  StreamSubscription<List<Event>>? _eventsSubscription;

  EventBloc({
    required this.createEventUseCase,
    required this.fetchEventsUseCase,
    required this.getUpcomingEvents,
    required this.toggleEventFavorite,
    required this.userId,
  }) : super(EventInitial()) {
    on<CreateEventRequested>(_onCreateEventRequested);
    on<FetchEventsRequested>(_onFetchEventsRequested);
    on<LoadUpcomingEvents>(_onLoadUpcomingEvents);
    on<ToggleFavoriteEvent>(_onToggleFavoriteEvent);

    // Load events when bloc is initialized
    add(LoadUpcomingEvents());
  }

  Future<void> _onCreateEventRequested(
    CreateEventRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(EventCreating());
    try {
      await createEventUseCase(event.event, event.imageFile);
      emit(EventCreatedSuccessfully());
      add(FetchEventsRequested()); // Refresh event list
    } catch (e) {
      emit(EventError('Failed to create event: $e'));
    }
  }

  Future<void> _onFetchEventsRequested(
    FetchEventsRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      final events = await fetchEventsUseCase();
      emit(EventLoaded(events));
    } catch (e) {
      emit(EventError('Failed to fetch events: ${e.toString()}'));
    }
  }

  // Proper async handling with emit.isDone checks
  Future<void> _onLoadUpcomingEvents(
    LoadUpcomingEvents event,
    Emitter<EventState> emit,
  ) async {
    // Cancel any existing subscription first
    await _eventsSubscription?.cancel();
    
    emit(state.copyWith(status: EventStatus.loading));

    try {
      // Set up the stream subscription with proper error handling
      _eventsSubscription = getUpcomingEvents().listen(
        (events) {
          // Check if emit is still valid before calling
          if (!emit.isDone) {
            emit(state.copyWith(
              status: EventStatus.success,
              events: events,
            ));
          }
        },
        onError: (error) {
          // Check if emit is still valid before calling
          if (!emit.isDone) {
            emit(state.copyWith(
              status: EventStatus.failure,
              errorMessage: error.toString(),
            ));
          }
        },
        cancelOnError: false, // Keep listening even if there's an error
      );
    } catch (e) {
      // Handle immediate errors (like subscription setup failures)
      if (!emit.isDone) {
        emit(state.copyWith(
          status: EventStatus.failure,
          errorMessage: 'Failed to set up events stream: ${e.toString()}',
        ));
      }
    }
  }

  Future<void> _onToggleFavoriteEvent(
    ToggleFavoriteEvent event,
    Emitter<EventState> emit,
  ) async {
    try {
      await toggleEventFavorite(event.eventId, userId, event.isFavorite);

      final newFavorites = Set<String>.from(state.favoriteEventIds);
      if (event.isFavorite) {
        newFavorites.add(event.eventId);
      } else {
        newFavorites.remove(event.eventId);
      }

      if (!emit.isDone) {
        emit(state.copyWith(favoriteEventIds: newFavorites));
      }
    } catch (error) {
      if (!emit.isDone) {
        emit(state.copyWith(errorMessage: error.toString()));
      }
    }
  }

  @override
  Future<void> close() async {
    await _eventsSubscription?.cancel();
    return super.close();
  }
}