import 'package:rovify/data/datasources/event_remote_datasource.dart';
import 'package:rovify/domain/entities/event.dart';
import 'package:rovify/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;

  EventRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<Event>> getUpcomingEvents() {
    return remoteDataSource.getUpcomingEvents();
  }

  @override
  Future<void> toggleFavorite(String eventId, String userId, bool isFavorite) {
    return remoteDataSource.toggleFavorite(eventId, userId, isFavorite);
  }
}