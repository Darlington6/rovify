import 'package:rovify/domain/entities/event.dart';
import 'dart:io';

abstract class EventRepository {
  Future<void> createEvent(Event event, File imageFile);
  Future<List<Event>> fetchEvents();

  Stream<List<Event>> getUpcomingEvents();
  Future<void> toggleFavorite(String eventId, String userId, bool isFavorite);
}