import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rovify/domain/entities/event.dart';

class EventModel extends Event {
  EventModel({
    required super.id,
    required super.title,
    required super.hostName,
    required super.hostImageUrl,
    required super.thumbnailUrl,
    required super.viewers,
    required super.followers,
    required super.isLive,
    required super.hostId,
    required super.type,
    required super.location,
    required super.category,
    required super.datetime,
    required super.description,
    required super.status,
    required super.ticketType,
    required super.createdAt,      
  });

  /// From Firestore Document Snapshot
  factory EventModel.fromMap(Map<String, dynamic> data, String docId) {
    return EventModel(
      id: docId,
      title: data['title'] ?? 'No Title',
      hostName: data['hostName'] ?? 'Unknown Host',
      hostImageUrl: data['hostImageUrl'] ?? 'https://via.placeholder.com/150',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      viewers: data['viewers'] ?? 0,
      followers: data['followers'] ?? 0,
      isLive: data['isLive'] ?? false,
      category: data['category'] ?? 'Popular',
      hostId: data['hostID'] ?? '',
      type: data['type'] ?? 'in-person',
      location: data['location'] ?? '',
      datetime: (data['datetime'] != null && data['datetime'] is Timestamp)
          ? (data['datetime'] as Timestamp).toDate()
          : DateTime.now(), // fallback to now
      description: data['description'] ?? '',
      status: data['status'] ?? 'upcoming',
      ticketType: data['ticketType'] ?? 'General',
      createdAt: (data['createdAt'] != null && data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(), // fallback
    );
  }

  /// To JSON (for Firestore)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'hostName': hostName,
      'hostImageUrl': hostImageUrl,
      'thumbnailUrl': thumbnailUrl,
      'viewers': viewers,
      'followers': followers,
      'isLive': isLive,
      'hostId': hostId,           
      'category': category,
      'hostID': hostId,
      'type': type,
      'location': location,
      'datetime': datetime,
      'description': description,
      'status': status,
      'ticketType': ticketType,
      'createdAt': createdAt,       
    };
  }

  /// From Domain Entity ➜ Model
  factory EventModel.fromEntity(Event event) {
    return EventModel(
      id: event.id,
      title: event.title,
      hostName: event.hostName,
      hostImageUrl: event.hostImageUrl,
      thumbnailUrl: event.thumbnailUrl,
      viewers: event.viewers,
      followers: event.followers,
      isLive: event.isLive,
      hostId: event.hostId,       
      category: event.category, 
      type: event.type, 
      location: event.location, 
      datetime: event.datetime, 
      description: event.description, 
      status: event.status, 
      ticketType: event.ticketType, 
      createdAt: event.createdAt,       
    );
  }

  /// From Model ➜ Domain Entity
  Event toEntity() {
    return Event(
      id: id,
      title: title,
      hostName: hostName,
      hostImageUrl: hostImageUrl,
      thumbnailUrl: thumbnailUrl,
      viewers: viewers,
      followers: followers,
      isLive: isLive,
      hostId: hostId,             
      category: category,
      type: type, 
      location: location, 
      datetime: datetime, 
      description: description, 
      status: status, 
      ticketType: ticketType, 
      createdAt: createdAt,             
    );
  }

  static fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return EventModel.fromMap(doc.data(), doc.id);
  }
}