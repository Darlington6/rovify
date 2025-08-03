import 'dart:io';
import 'package:rovify/domain/entities/event.dart';
import 'package:rovify/domain/repositories/event_repository.dart';

class CreateEvent {
  final EventRepository repository;

  CreateEvent(this.repository);

  Future<void> call(Event event, File imageFile) async {
    return await repository.createEvent(event, imageFile);
  }
}