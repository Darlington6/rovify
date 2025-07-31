import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:rovify/domain/usecases/events/get_upcoming_events.dart';
import 'package:rovify/domain/usecases/events/toggle_event_favorite.dart';
import 'package:rovify/domain/entities/event.dart';

part 'event_event.dart';
part 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final GetUpcomingEvents getUpcomingEvents;
  final ToggleEventFavorite toggleEventFavorite;
  final String userId;

  late StreamSubscription<List<Event>> _eventsSubscription;

  EventBloc({
    required this.getUpcomingEvents,
    required this.toggleEventFavorite,
    required this.userId,
  }) : super(const EventState()) {
    on<LoadUpcomingEvents>(_onLoadUpcomingEvents);
    on<ToggleFavoriteEvent>(_onToggleFavoriteEvent);

    // Load events when bloc is initialized
    add(LoadUpcomingEvents());
  }

  Future<void> _onLoadUpcomingEvents(
    LoadUpcomingEvents event,
    Emitter<EventState> emit,
  ) async {
    emit(state.copyWith(status: EventStatus.loading));

    _eventsSubscription = getUpcomingEvents().listen(
      (events) {
        emit(state.copyWith(
          status: EventStatus.success,
          events: events,
        ));
      },
      onError: (error) {
        emit(state.copyWith(
          status: EventStatus.failure,
          errorMessage: error.toString(),
        ));
      },
    );
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

      emit(state.copyWith(favoriteEventIds: newFavorites));
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  @override
  Future<void> close() {
    _eventsSubscription.cancel();
    return super.close();
  }
}