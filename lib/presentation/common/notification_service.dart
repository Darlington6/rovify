import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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

// Notifications Screen
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('Please sign in to view notifications'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              NotificationService.markAllAsRead(user.uid);
            },
            child: const Text(
              'Mark all read',
              style: TextStyle(
                color: Colors.blue,
                fontFamily: 'Onest',
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading notifications: ${snapshot.error}'),
            );
          }

          final notifications = snapshot.data?.docs ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'You currently do not have any notifications. All in-app notifications will be found here...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontFamily: 'Onest',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final notificationData = notification.data() as Map<String, dynamic>;
              
              final title = notificationData['title'] ?? 'Notification';
              final message = notificationData['message'] ?? '';
              final isRead = notificationData['isRead'] ?? false;
              final createdAt = notificationData['createdAt'] as Timestamp?;
              final type = notificationData['type'] ?? '';
              
              final timeText = createdAt != null 
                  ? _formatNotificationTime(createdAt.toDate())
                  : 'Just now';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: isRead ? 0 : 2,
                color: isRead ? Colors.white : Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                  side: BorderSide(
                    color: isRead ? Colors.grey.shade200 : Colors.blue.shade200,
                    width: 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getNotificationIconColor(type),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _getNotificationIcon(type),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    title,
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Onest',
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 14,
                          color: isRead ? Colors.grey : Colors.black87,
                          fontFamily: 'Onest',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        timeText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontFamily: 'Onest',
                        ),
                      ),
                    ],
                  ),
                  trailing: !isRead
                      ? Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                  onTap: () {
                    if (!isRead) {
                      NotificationService.markAsRead(notification.id);
                    }
                    _handleNotificationTap(context, notificationData);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'ticket_booked':
        return Icons.confirmation_number;
      case 'event_reminder':
        return Icons.event;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationIconColor(String type) {
    switch (type) {
      case 'ticket_booked':
        return Colors.green;
      case 'event_reminder':
        return Colors.blue;
      case 'payment':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(dateTime);
    }
  }

  void _handleNotificationTap(BuildContext context, Map<String, dynamic> notificationData) {
    final type = notificationData['type'] ?? '';
    final data = notificationData['data'] as Map<String, dynamic>? ?? {};

    switch (type) {
      case 'ticket_booked':
        // Navigate to ticket details for more info
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Ticket Details',
              style: const TextStyle(fontFamily: 'Onest'),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Event: ${data['eventTitle'] ?? 'Unknown'}'),
                Text('Ticket ID: ${data['ticketId'] ?? 'Unknown'}'),
                Text('Quantity: ${data['quantity'] ?? 0}'),
                Text('Total: Kes ${(data['totalPrice'] ?? 0.0).toStringAsFixed(2)}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
        break;
      default:
        // Handle other notification types
        break;
    }
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