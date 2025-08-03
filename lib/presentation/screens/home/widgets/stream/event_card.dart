import 'dart:math' as developer;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventCard extends StatefulWidget {
  final String title;
  final String thumbnailUrl;
  final String hostName;
  final String hostId;
  final int followers;
  final int viewers;
  final bool isLive;

  const EventCard({
    super.key,
    required this.title,
    required this.thumbnailUrl,
    required this.hostName,
    required this.hostId,
    required this.followers,
    required this.viewers,
    required this.isLive,
    required hostImageUrl,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  String? dynamicHostName;
  bool isLoadingHostName = false;

  @override
  void initState() {
    super.initState();
    _fetchCreatorName();
  }

  Future<void> _fetchCreatorName() async {
    if (widget.hostId.isEmpty) {
      if (mounted) {
        setState(() => dynamicHostName = 'Unknown Host');
      }
      return;
    }

    if (mounted) {
      setState(() => isLoadingHostName = true);
    }

    try {
      // First try to get from Firestore (creator's profile)
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.hostId)
          .get();

      String? creatorName;

      if (userDoc.exists) {
        final userData = userDoc.data();
        // Try different possible field names for display name
        creatorName = userData?['displayName'] ?? 
                     userData?['name'] ?? 
                     userData?['fullName'];
      }

      // If no custom name in Firestore, try Google account name
      if (creatorName == null || creatorName.isEmpty) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.uid == widget.hostId) {
          creatorName = currentUser.displayName;
        }
      }

      // Final fallback
      creatorName ??= 'Unknown Host';

      if (mounted) {
        setState(() {
          dynamicHostName = creatorName;
          isLoadingHostName = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching creator name: $e');
      if (mounted) {
        setState(() {
          dynamicHostName = 'Unknown Host';
          isLoadingHostName = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;
    
    // Calculate card height based on screen height and orientation
    final cardHeight = orientation == Orientation.portrait 
        ? screenHeight * 0.32
        : screenHeight * 0.8;

    final compactViewers = NumberFormat.compact().format(widget.viewers);
    final compactFollowers = NumberFormat.compact().format(widget.followers);

    // Use dynamic name if available, otherwise use the passed hostName as fallback
    final displayName = dynamicHostName ?? widget.hostName;

    return SizedBox(
      height: cardHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.network(
                    widget.thumbnailUrl.isNotEmpty
                        ? widget.thumbnailUrl
                        : 'https://via.placeholder.com/300x200.png?text=No+Image',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(Icons.broken_image, size: 40),
                        ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 11,
                  child: widget.isLive
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Live',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                Positioned(
                  top: 12,
                  left: 11,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0x80000000),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      compactViewers,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3,
                          color: Colors.black87,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // Use FutureBuilder implementation for profile image
                FutureBuilder<String?>(
                  future: _getUserProfileImage(widget.hostId),
                  builder: (context, snapshot) {
                    final profileImageUrl = snapshot.data;
                    
                    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
                      // Show network image with error handling
                      return CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: NetworkImage(profileImageUrl),
                        onBackgroundImageError: (exception, stackTrace) {
                          // Handle image loading error silently
                        },
                      );
                    } else {
                      // Show default avatar
                      return CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[300],
                        child: Icon(
                          Icons.person,
                          size: 24,
                          color: Colors.grey[600],
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isLoadingHostName
                          ? const SizedBox(
                              width: 100,
                              height: 14,
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.grey,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            )
                          : Text(
                              displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600, 
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      const SizedBox(height: 2),
                      Text(
                        '$compactFollowers Followers',
                        style: const TextStyle(
                          fontSize: 12, 
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get user profile image
  Future<String?> _getUserProfileImage(String userId) async {
    try {
      // First check if this is the current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.uid == userId) {
        // Return the current user's photo URL (from Google Sign-In)
        return currentUser.photoURL;
      }
      
      // For now, return null for other users
      return null;
    } catch (e) {
      developer.log('Error getting user profile image: $e' as num);
      return null;
    }
  }
}