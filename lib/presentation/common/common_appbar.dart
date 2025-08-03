import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:developer' as developer;

import 'package:rovify/presentation/common/notification_service.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? location; // Made optional - will auto-detect if null
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final double height;
  final EdgeInsetsGeometry contentPadding;

  const CommonAppBar({
    super.key,
    this.location, // If null, will auto-detect user's location
    this.onNotificationTap,
    this.onProfileTap,
    this.height = 76,
    this.contentPadding = const EdgeInsets.fromLTRB(26, 12, 26, 12),
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  // Fetch user data from Firestore
  Future<Map<String, dynamic>?> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      return doc.exists ? doc.data() : null;
    } catch (e) {
      // Use developer.log instead of print for production
      developer.log('Error fetching user data: $e', name: 'CommonAppBar');
      return null;
    }
  }

  // Get user's current location automatically
  Future<String> _getUserLocation() async {
    try {
      // Check if location permission is granted
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Location unavailable';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return 'Location unavailable';
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          timeLimit: const Duration(seconds: 10),
        ),
      );

      // Convert coordinates to address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        // Format: "City, Country" (e.g., "Nairobi, Kenya")
        final city = placemark.locality ?? placemark.administrativeArea ?? 'Unknown City';
        final country = placemark.country ?? 'Unknown Country';
        return '$city, $country';
      }

      return 'Location unavailable';
    } catch (e) {
      developer.log('Error getting user location: $e', name: 'CommonAppBar');
      return 'Location unavailable';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final double dynamicHeight = isLandscape ? 64 : height;
    final EdgeInsetsGeometry dynamicPadding =
        isLandscape ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8) : contentPadding;

    return AppBar(
      toolbarHeight: dynamicHeight,
      backgroundColor: const Color(0xFFF5F5F5),
      elevation: 0.5,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: dynamicPadding,
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _fetchUserData(),
          builder: (context, snapshot) {
            // Extract avatar URL from Firebase data
            final avatarUrl = snapshot.data?['avatarUrl'] as String?;
            
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Profile Avatar with Firebase integration
                GestureDetector(
                  onTap: onProfileTap ?? () {
                    // Default behavior: open drawer if no custom onTap provided
                    Scaffold.of(context).openDrawer();
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _buildProfileImage(avatarUrl),
                    child: _buildProfileChild(avatarUrl, snapshot),
                  ),
                ),

                // Location Info with auto-detection
                _buildLocationSection(),

                // Notification Icon with Badge
                NotificationBadge(onTap: onNotificationTap),
              ],
            );
          },
        ),
      ),
    );
  }

  // Build location section with auto-detection
  Widget _buildLocationSection() {
    return FutureBuilder<String>(
      future: location != null ? Future.value(location!) : _getUserLocation(),
      builder: (context, locationSnapshot) {
        final displayLocation = locationSnapshot.data ?? 'Loading location...';
        final isLoading = locationSnapshot.connectionState == ConnectionState.waiting;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Location',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8D8D8D),
                fontFamily: 'Onest',
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                  )
                else
                  const Icon(Icons.location_on, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Text(
                  displayLocation,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF000000),
                    fontFamily: 'Onest',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Helper method to build profile image
  ImageProvider? _buildProfileImage(String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return NetworkImage(avatarUrl);
    }
    return null;
  }

  // Helper method to build profile child (fallback icon)
  Widget? _buildProfileChild(String? avatarUrl, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      );
    }
    
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return const Icon(Icons.person, color: Colors.grey, size: 18);
    }
    
    return null;
  }
}

// Notification Badge Widget for AppBar
class NotificationBadge extends StatelessWidget {
  final VoidCallback? onTap;

  const NotificationBadge({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return IconButton(
        onPressed: onTap,
        icon: const Icon(
          Icons.notifications_none,
          color: Colors.black87,
          size: 24,
        ),
      );
    }

    return StreamBuilder<int>(
      stream: NotificationService.getUnreadNotificationCount(user.uid),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;
        
        return Stack(
          children: [
            IconButton(
              onPressed: onTap ?? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.notifications_none,
                color: Colors.black87,
                size: 24,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Onest',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// Notification Service Class
class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a notification when a ticket is booked
  static Future<void> createTicketBookingNotification({
    required String userId,
    required String eventTitle,
    required String ticketId,
    required int quantity,
    required double totalPrice,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'type': 'ticket_booked',
        'title': 'Ticket Booking Confirmed',
        'message': 'Your ticket for "$eventTitle" has been confirmed. Total: Kes ${totalPrice.toStringAsFixed(2)}',
        'data': {
          'eventTitle': eventTitle,
          'ticketId': ticketId,
          'quantity': quantity,
          'totalPrice': totalPrice,
        },
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log('Error creating notification: $e');
    }
  }

  // Get unread notification count
  static Stream<int> getUnreadNotificationCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read for a user
  static Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in notifications.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      developer.log('Error marking all notifications as read: $e');
    }
  }
}