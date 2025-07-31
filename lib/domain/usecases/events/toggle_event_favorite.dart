import 'package:rovify/domain/repositories/event_repository.dart';

class ToggleEventFavorite {
  final EventRepository repository;

  ToggleEventFavorite(this.repository);

  Future<void> call(String eventId, String userId, bool isFavorite) {
    return repository.toggleFavorite(eventId, userId, isFavorite);
  }
}