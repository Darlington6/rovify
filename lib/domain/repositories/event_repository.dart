import 'package:rovify/domain/entities/event.dart';

abstract class EventRepository {
  Stream<List<Event>> getUpcomingEvents();
  Future<void> toggleFavorite(String eventId, String userId, bool isFavorite);
}