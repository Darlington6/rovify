import 'package:rovify/domain/entities/event.dart';
import 'package:rovify/domain/repositories/event_repository.dart';

class GetUpcomingEvents {
  final EventRepository repository;

  GetUpcomingEvents(this.repository);

  Stream<List<Event>> call() {
    return repository.getUpcomingEvents();
  }
}