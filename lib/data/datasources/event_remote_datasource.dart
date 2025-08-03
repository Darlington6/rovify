import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/event_model.dart';

abstract class EventRemoteDataSource {
  Future<void> createEvent(EventModel event, File imageFile);
  Future<List<EventModel>> fetchEvents();
  Stream<List<EventModel>> getUpcomingEvents();
  Future<void> toggleFavorite(String eventId, String userId, bool isFavorite);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  EventRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
  });

  @override
  Future<void> createEvent(EventModel event, File imageFile) async {
    try {
      final ref = storage.ref().child('event_thumbnails/${event.id}.jpg');
      await ref.putFile(imageFile);
      final thumbnailUrl = await ref.getDownloadURL();

      await firestore.collection('events').doc(event.id).set(
            event.copyWith(thumbnailUrl: thumbnailUrl).toJson(),
          );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<EventModel>> fetchEvents() async {
    try {
      final snapshot = await firestore
          .collection('events')
          .get()
          .timeout(const Duration(seconds: 10));
      return snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<List<EventModel>> getUpcomingEvents() {
    return firestore
        .collection('events')
        .where('status', isEqualTo: 'upcoming')
        .orderBy('datetime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map<EventModel>((doc) => EventModel.fromFirestore(doc))
            .toList());
  }

  @override
  Future<void> toggleFavorite(
      String eventId, String userId, bool isFavorite) async {
    final userRef = firestore.collection('users').doc(userId);

    await firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) {
        transaction.set(userRef, {'favorites': []});
      }

      if (isFavorite) {
        transaction.update(userRef, {
          'favorites': FieldValue.arrayUnion([eventId])
        });
      } else {
        transaction.update(userRef, {
          'favorites': FieldValue.arrayRemove([eventId])
        });
      }
    });
  }
}

extension EventModelCopyWith on EventModel {
  EventModel copyWith({
    String? id,
    String? title,
    String? hostName,
    String? thumbnailUrl,
    String? hostImageUrl,
    int? viewers,
    int? followers,
    bool? isLive,
    String? hostId,
    String? category,
    String? type,
    String? location,
    DateTime? datetime,
    String? description,
    String? status,
    String? ticketType,
    DateTime? createdAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      hostName: hostName ?? this.hostName,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      hostImageUrl: hostImageUrl ?? this.hostImageUrl,
      viewers: viewers ?? this.viewers,
      followers: followers ?? this.followers,
      isLive: isLive ?? this.isLive,
      hostId: hostId ?? this.hostId,
      category: category ?? this.category,
      type: type ?? this.type,
      location: location ?? this.location,
      datetime: datetime ?? this.datetime,
      description: description ?? this.description,
      status: status ?? this.status,
      ticketType: ticketType ?? this.ticketType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}