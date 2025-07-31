import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rovify/domain/entities/event.dart';

class EventModel extends Event {
  const EventModel({
    required super.id,
    required super.title,
    required super.hostId,
    required super.type,
    required super.location,
    required super.category,
    required super.datetime,
    required super.description,
    required super.status,
    required super.thumbnailUrl,
    required super.ticketType,
    required super.createdAt,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      hostId: data['hostID'] ?? '',
      type: data['type'] ?? 'in-person',
      location: data['location'] ?? '',
      category: data['category'] ?? '',
      datetime: (data['datetime'] as Timestamp).toDate(),
      description: data['description'] ?? '',
      status: data['status'] ?? 'upcoming',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      ticketType: data['ticketType'] ?? 'General',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'hostID': hostId,
      'type': type,
      'location': location,
      'category': category,
      'datetime': datetime,
      'description': description,
      'status': status,
      'thumbnailUrl': thumbnailUrl,
      'ticketType': ticketType,
      'createdAt': createdAt,
    };
  }
}