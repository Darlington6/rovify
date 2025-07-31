import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CreatorDashboardScreen extends StatefulWidget {
  final String userId;
  const CreatorDashboardScreen({super.key, required this.userId});

  @override
  State<CreatorDashboardScreen> createState() => _CreatorDashboardScreenState();
}

class _CreatorDashboardScreenState extends State<CreatorDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Creator Dashboard',
          style: TextStyle(fontFamily: 'Onest', fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createNewEvent(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _getSelectedScreen(),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      selectedLabelStyle: const TextStyle(fontFamily: 'Onest'),
      unselectedLabelStyle: const TextStyle(fontFamily: 'Onest'),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'My Events',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Scan Tickets',
        ),
      ],
    );
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardScreen();
      case 1:
        return _buildMyEventsScreen();
      case 2:
        return _buildScanTicketsScreen();
      default:
        return _buildDashboardScreen();
    }
  }

  Widget _buildDashboardScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Overview',
          style: TextStyle(
            fontFamily: 'Onest',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('events')
                .where('hostID', isEqualTo: widget.userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final events = snapshot.data!.docs;

              if (events.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/splash-images/image1.png', height: 150),
                      const SizedBox(height: 20),
                      const Text(
                        'No events created yet',
                        style: TextStyle(fontFamily: 'Onest', fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _createNewEvent(context),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Create First Event',
                          style: TextStyle(fontFamily: 'Onest'),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Calculate stats
              int totalEvents = events.length;
              int upcomingEvents = events.where((event) {
                final date = event['datetime']?.toDate();
                return date != null && date.isAfter(DateTime.now());
              }).length;

              return Column(
                children: [
                  Row(
                    children: [
                      _buildStatCard(
                        context,
                        'Total Events',
                        totalEvents.toString(),
                        Icons.event,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        context,
                        'Upcoming',
                        upcomingEvents.toString(),
                        Icons.upcoming,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _buildEventsList(events),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      BuildContext context, String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Onest',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Onest',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyEventsScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Events',
          style: TextStyle(
            fontFamily: 'Onest',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('events')
                .where('hostID', isEqualTo: widget.userId)
                .orderBy('datetime', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _buildErrorWidget('Error loading events');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final events = snapshot.data?.docs ?? [];

              if (events.isEmpty) {
                return _buildEmptyEventsWidget();
              }

              return _buildEventsList(events);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventsList(List<QueryDocumentSnapshot> events) {
    return ListView.separated(
      itemCount: events.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = events[index].data() as Map<String, dynamic>;
        final eventId = events[index].id;
        final dateTime = event['datetime']?.toDate();
        final isPastEvent = dateTime?.isBefore(DateTime.now()) ?? false;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _navigateToEventDetails(eventId),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event['title'] ?? 'Untitled Event',
                          style: const TextStyle(
                            fontFamily: 'Onest',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPastEvent
                              ? Colors.white
                              : Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isPastEvent ? 'Completed' : 'Upcoming',
                          style: TextStyle(
                            fontFamily: 'Onest',
                            color: isPastEvent
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (dateTime != null)
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16,
                            color: Theme.of(context).colorScheme.secondary),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMM d, y • h:mm a').format(dateTime),
                          style: const TextStyle(fontFamily: 'Onest'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event['location'] ?? 'Location not specified',
                          style: const TextStyle(fontFamily: 'Onest'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('tickets')
                        .where('eventID', isEqualTo: eventId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final totalTickets = snapshot.data?.docs.length ?? 0;
                      final checkedInTickets = snapshot.data?.docs
                              .where((ticket) =>
                                  (ticket.data() as Map<String, dynamic>)['isCheckedIn'] == true)
                              .length ??
                          0;

                      return Row(
                        children: [
                          _buildTicketStat(
                            context,
                            'Total',
                            totalTickets.toString(),
                          ),
                          const SizedBox(width: 16),
                          _buildTicketStat(
                            context,
                            'Checked In',
                            '$checkedInTickets/$totalTickets',
                            isCheckedIn: true,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTicketStat(
      BuildContext context, String label, String value,
      {bool isCheckedIn = false}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isCheckedIn
                ? Colors.green
                : Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Onest',
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Onest',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScanTicketsScreen() {
    return Column(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Icon(Icons.qr_code_scanner,
                    size: 64, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                const Text(
                  'Scan Attendee Tickets',
                  style: TextStyle(
                    fontFamily: 'Onest',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Point your camera at a ticket QR code to check in attendees',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Onest', color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _scanQRCode(context),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text(
                    'Scan QR Code',
                    style: TextStyle(fontFamily: 'Onest'),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Recent Check-ins',
          style: TextStyle(
            fontFamily: 'Onest',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('tickets')
                .where('eventHostId', isEqualTo: widget.userId)
                .where('isCheckedIn', isEqualTo: true)
                .orderBy('checkInTime', descending: true)
                .limit(10)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _buildErrorWidget('Error loading check-ins');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final tickets = snapshot.data?.docs ?? [];

              if (tickets.isEmpty) {
                return const Center(
                  child: Text(
                    'No recent check-ins',
                    style: TextStyle(fontFamily: 'Onest'),
                  ),
                );
              }

              return ListView.separated(
                itemCount: tickets.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final ticket = tickets[index].data() as Map<String, dynamic>;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(Icons.person,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    title: Text(
                      ticket['attendeeName'] ?? 'Anonymous',
                      style: const TextStyle(fontFamily: 'Onest'),
                    ),
                    subtitle: Text(
                      'Event: ${ticket['eventTitle'] ?? 'Unknown'}',
                      style: const TextStyle(fontFamily: 'Onest'),
                    ),
                    trailing: Text(
                      ticket['checkInTime'] != null 
                          ? DateFormat('h:mm a').format(
                              (ticket['checkInTime'] as Timestamp).toDate())
                          : 'N/A',
                      style: const TextStyle(fontFamily: 'Onest'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Onest',
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          TextButton(
            onPressed: () => setState(() {}),
            child: const Text('Retry', style: TextStyle(fontFamily: 'Onest')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyEventsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/splash-images/image1.png', height: 150),
          const SizedBox(height: 20),
          const Text(
            'No events created yet',
            style: TextStyle(fontFamily: 'Onest', fontSize: 18),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _createNewEvent(context),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
            ),
            
          ), child: null,
          )
        ],
      ),
    );
  }

  void _createNewEvent(BuildContext context) {
    Navigator.pushNamed(context, 'addEvent', arguments: widget.userId);
  }

  void _navigateToEventDetails(String eventId) {
    Navigator.pushNamed(
      context, 
      'eventDetails', 
      arguments: {
        'eventId': eventId,
        'userId': widget.userId,
      },
    );
  }

  void _scanQRCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan QR Code', style: TextStyle(fontFamily: 'Onest')),
        content: const Text(
          'QR code scanning functionality would be implemented here',
          style: TextStyle(fontFamily: 'Onest'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(fontFamily: 'Onest')),
          ),
        ],
      ),
    );
  }
}