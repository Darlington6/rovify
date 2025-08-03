import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:rovify/presentation/screens/home/widgets/creator/edit_event_screen.dart'; 

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  final String userId;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
    required this.userId,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger('EventDetailsScreen');
  
  late Stream<DocumentSnapshot> _eventStream;
  late Stream<QuerySnapshot> _ticketsStream;
  final Map<String, String> _userDisplayNames = {};
  final Map<String, Future<String>> _userDisplayNameFutures = {};

  @override
  void initState() {
    super.initState();
    _eventStream = _firestore.collection('events').doc(widget.eventId).snapshots();
    _ticketsStream = _firestore
        .collection('tickets')
        .where('eventID', isEqualTo: widget.eventId)
        .snapshots();
  }

  Future<String> _getUserDisplayName(String userID) async {
    if (userID.isEmpty) return 'Guest';
    
    // Return cached result if available
    if (_userDisplayNames.containsKey(userID)) {
      return _userDisplayNames[userID]!;
    }

    // Return existing future if already loading
    if (_userDisplayNameFutures.containsKey(userID)) {
      return _userDisplayNameFutures[userID]!;
    }

    // Create and cache the future
    final future = _fetchUserDisplayName(userID);
    _userDisplayNameFutures[userID] = future;
    
    return future;
  }

  Future<String> _fetchUserDisplayName(String userID) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userID).get();
      final displayName = userDoc.data()?['displayName'] ?? 'Guest';
      
      // Cache the result
      _userDisplayNames[userID] = displayName;
      
      return displayName;
    } catch (e) {
      _logger.warning('Error fetching user display name for $userID: $e');
      return 'Guest';
    }
  }

  // Safe substring method that handles short strings
  String _getSafeSubstring(String text, int maxLength) {
    if (text.isEmpty) return 'Not set';
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength);
  }

  // Safe ticket ID display
  String _getTicketIdDisplay(String id) {
    if (id.isEmpty) return 'Not set';
    return _getSafeSubstring(id, 8);
  }

  Future<void> _editEvent() async {
    try {
      final eventDoc = await _firestore.collection('events').doc(widget.eventId).get();
      
      // Check if widget is still mounted after async operation
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditEventScreen(
            eventData: eventDoc.data() as Map<String, dynamic>,
            eventId: widget.eventId,
            userId: widget.userId,
          ),
        ),
      );
    } catch (e) {
      _logger.severe('Error loading event for edit: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading event data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteEvent() async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Event'),
          content: const Text('Are you sure you want to delete this event and all tickets?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      // Check if widget is still mounted after dialog
      if (!mounted) return;

      if (confirmed == true) {
        try {
          final tickets = await _firestore
              .collection('tickets')
              .where('eventID', isEqualTo: widget.eventId)
              .get();

          // Check if widget is still mounted after Firestore operation
          if (!mounted) return;

          final batch = _firestore.batch();
          for (var ticket in tickets.docs) {
            batch.delete(ticket.reference);
          }
          batch.delete(_firestore.collection('events').doc(widget.eventId));
          await batch.commit();

          // Check if widget is still mounted before navigation
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Event deleted successfully'),
              backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          _logger.severe('Error deleting event: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to delete event'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      _logger.severe('Error showing delete dialog: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error showing delete dialog'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleCheckIn(String ticketId, bool status) async {
    try {
      await _firestore.collection('tickets').doc(ticketId).update({
        'isCheckedIn': status,
        'checkInTime': status ? FieldValue.serverTimestamp() : null,
      });
    } catch (e) {
      _logger.warning('Error toggling check-in for ticket $ticketId: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update check-in'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refundTicket(String ticketId, int quantity) async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Refund Ticket'),
          content: Text('Are you sure you want to refund this ticket${quantity > 1 ? ' ($quantity tickets)' : ''}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Refund', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      // Check if widget is still mounted after dialog
      if (!mounted) return;

      if (confirmed == true) {
        try {
          await _firestore.collection('tickets').doc(ticketId).delete();
          await _firestore.collection('events').doc(widget.eventId).update({
            'ticketsSold': FieldValue.increment(-quantity), // Use the actual quantity
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ticket${quantity > 1 ? 's' : ''} refunded successfully'), 
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          _logger.severe('Error refunding ticket $ticketId: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to refund ticket'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      _logger.severe('Error showing refund dialog: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error processing refund'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTicketStats(Map<String, dynamic> event) {
    final sold = event['ticketsSold'] ?? 0;
    final total = event['totalTickets'] ?? '∞';
    return '$sold/$total';
  }

  Widget _buildTicketItem(DocumentSnapshot ticketDoc, int index) {
    try {
      final ticket = ticketDoc.data() as Map<String, dynamic>;
      final id = ticketDoc.id;
      final isCheckedIn = ticket['isCheckedIn'] ?? false;
      final userID = ticket['userID'] ?? '';
      final quantity = ticket['metadata']?['quantity'] ?? 1;

      return FutureBuilder<String>(
        future: _getUserDisplayName(userID),
        builder: (context, snapshot) {
          final name = snapshot.data ?? 'Loading...';

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                isCheckedIn ? Icons.check_circle : Icons.person,
                color: isCheckedIn ? Colors.green : Colors.blue,
              ),
              title: Text(
                name,
                style: const TextStyle(fontFamily: 'Onest'),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ticket ID: ${_getTicketIdDisplay(id)}',
                    style: const TextStyle(fontFamily: 'Onest'),
                  ),
                  if (quantity > 1)
                    Text(
                      'Quantity: $quantity',
                      style: const TextStyle(fontFamily: 'Onest', fontWeight: FontWeight.w500),
                    ),
                  if (ticket['checkInTime'] != null)
                    Text(
                      'Checked in: ${DateFormat('h:mm a').format((ticket['checkInTime'] as Timestamp).toDate())}',
                      style: const TextStyle(fontFamily: 'Onest'),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(isCheckedIn ? Icons.undo : Icons.check),
                    color: isCheckedIn ? Colors.grey : Colors.green,
                    onPressed: () => _toggleCheckIn(id, !isCheckedIn),
                    tooltip: isCheckedIn ? 'Undo check-in' : 'Check in',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () => _refundTicket(id, quantity),
                    tooltip: 'Refund ticket',
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      _logger.warning('Error building ticket item at index $index: $e');
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const Icon(Icons.error, color: Colors.red),
          title: Text(
            'Error loading ticket',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontFamily: 'Onest',
            ),
          ),
          subtitle: Text(
            'Ticket ID: ${_getTicketIdDisplay(ticketDoc.id)}',
            style: const TextStyle(fontFamily: 'Onest'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Event Details',
          style: TextStyle(fontFamily: 'Onest', fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editEvent,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteEvent,
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _eventStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            _logger.severe('Error loading event: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading event details',
                    style: TextStyle(
                      fontFamily: 'Onest',
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry', style: TextStyle(fontFamily: 'Onest')),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final eventData = snapshot.data!.data();
          if (eventData == null) {
            return const Center(
              child: Text(
                'Event not found',
                style: TextStyle(fontFamily: 'Onest'),
              ),
            );
          }

          final event = eventData as Map<String, dynamic>;
          final dateTime = (event['datetime'] as Timestamp).toDate();
          final isPast = dateTime.isBefore(DateTime.now());

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'] ?? 'No title',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Onest',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              DateFormat('EEE, MMM d, yyyy • h:mm a').format(dateTime),
                              style: const TextStyle(fontFamily: 'Onest'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              event['location'] ?? 'No location',
                              style: const TextStyle(fontFamily: 'Onest'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        event['description'] ?? 'No description',
                        style: const TextStyle(fontFamily: 'Onest'),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _buildStatCard(
                            'Tickets',
                            _getTicketStats(event),
                            Icons.confirmation_number,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            'Status',
                            isPast ? 'Completed' : 'Upcoming',
                            isPast ? Icons.check_circle : Icons.upcoming,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Attendees',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Onest',
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _ticketsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    _logger.warning('Error loading tickets: ${snapshot.error}');
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'Error loading attendees',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontFamily: 'Onest',
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final tickets = snapshot.data!.docs;
                  if (tickets.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'No tickets sold yet',
                            style: TextStyle(fontFamily: 'Onest'),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildTicketItem(tickets[index], index),
                        );
                      },
                      childCount: tickets.length,
                    ),
                  );
                },
              ),
              // Add bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
            ],
          );
        },
      ),
    );
  }
}