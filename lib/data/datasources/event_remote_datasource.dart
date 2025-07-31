import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rovify/data/models/event_model.dart';

class EventRemoteDataSource {
  final FirebaseFirestore _firestore;

  EventRemoteDataSource(this._firestore);

  Stream<List<EventModel>> getUpcomingEvents() {
    return _firestore
        .collection('events')
        .where('status', isEqualTo: 'upcoming')
        .orderBy('datetime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromFirestore(doc))
            .toList());
  }

  Future<void> toggleFavorite(String eventId, String userId, bool isFavorite) {
    final userRef = _firestore.collection('users').doc(userId);
    
    return _firestore.runTransaction((transaction) async {
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