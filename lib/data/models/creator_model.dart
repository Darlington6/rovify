import 'package:cloud_firestore/cloud_firestore.dart';

class Creator {
  final String id;
  final String bio;
  final Map<String, String> socials;
  final List<String> eventsHosted;
  final bool walletConnected;
  final DateTime createdAt;

  Creator({
    required this.id,
    required this.bio,
    required this.socials,
    required this.eventsHosted,
    required this.walletConnected,
    required this.createdAt,
  });

  factory Creator.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Creator(
      id: doc.id,
      bio: data['bio'] ?? '',
      socials: Map<String, String>.from(data['socials'] ?? {}),
      eventsHosted: List<String>.from(data['eventsHosted'] ?? []),
      walletConnected: data['walletConnected'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bio': bio,
      'socials': socials,
      'eventsHosted': eventsHosted,
      'walletConnected': walletConnected,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}