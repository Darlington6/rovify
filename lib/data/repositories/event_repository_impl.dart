import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rovify/data/datasources/event_remote_datasource.dart';
import 'package:rovify/data/models/event_model.dart';
import 'package:rovify/domain/entities/event.dart';
import 'package:rovify/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;


  EventRepositoryImpl(FirebaseFirestore firestore, {required this.remoteDataSource});

  @override
  Future<void> createEvent(Event event, File imageFile) async {
    final model = EventModel.fromEntity(event);
    await remoteDataSource.createEvent(model, imageFile);
  }

  @override
  Future<List<Event>> fetchEvents() async {
    final models = await remoteDataSource.fetchEvents();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Stream<List<Event>> getUpcomingEvents() {
    return remoteDataSource.getUpcomingEvents();
  }

   @override
  Future<void> toggleFavorite(String eventId, String userId, bool isFavorite) {
    return remoteDataSource.toggleFavorite(eventId, userId, isFavorite);
  }
}