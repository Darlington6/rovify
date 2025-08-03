import 'package:rovify/domain/entities/event.dart';
import 'package:rovify/domain/repositories/event_repository.dart';

class FetchEvents {
  final EventRepository repository;

  FetchEvents(this.repository);

  Future<List<Event>> call() async {
    return await repository.fetchEvents();
  }
}