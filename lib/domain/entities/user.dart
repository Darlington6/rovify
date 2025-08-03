// domain/entities/user.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final List<String>? interests;
  final String? walletAddress;
  final bool isCreator;
  final DateTime joinedAt;

  const User({
    required this.id,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.interests,
    this.walletAddress,
    this.isCreator = false,
    required this.joinedAt,
  });

  // Factory constructor to create User from Firestore map
  factory User.fromMap(String id, Map<String, dynamic> data) {
    return User(
      id: id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'],
      interests: List<String>.from(data['interests'] ?? []),
      walletAddress: data['walletAddress'],
      isCreator: data['isCreator'] ?? false,
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
    );
  }

  // Convert User to map for saving in Firestore
  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'avatarUrl': avatarUrl,
      'interests': interests,
      'walletAddress': walletAddress,
      'isCreator': isCreator,
      'joinedAt': joinedAt,
    };
  }
}