import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:rovify/presentation/screens/home/widgets/creator/event_details_screen.dart';
import 'package:rovify/presentation/screens/home/widgets/creator/qr_scanner_screen.dart';

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createNewEvent(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 16.0, left: 16.0,),
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
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        
        return StreamBuilder<QuerySnapshot>(
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
              return _buildEmptyDashboard(isLandscape);
            }

            // Calculate stats
            int totalEvents = events.length;
            int upcomingEvents = events.where((event) {
              final date = event['datetime']?.toDate();
              return date != null && date.isAfter(DateTime.now());
            }).length;

            return _buildDashboardContent(
              isLandscape: isLandscape,
              totalEvents: totalEvents,
              upcomingEvents: upcomingEvents,
              events: events,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyDashboard(bool isLandscape) {
    final content = Column(
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
    );

    if (isLandscape) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 
                       AppBar().preferredSize.height - 
                       MediaQuery.of(context).padding.top - 
                       kBottomNavigationBarHeight,
          ),
          child: content,
        ),
      );
    }

    return Center(child: content);
  }

  Widget _buildDashboardContent({
    required bool isLandscape,
    required int totalEvents,
    required int upcomingEvents,
    required List<QueryDocumentSnapshot> events,
  }) {
    final header = Text(
      'Event Overview',
      style: TextStyle(
        fontFamily: 'Onest',
        fontSize: 24,
        color: Colors.grey[600]
      ),
    );

    final statsRow = Row(
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
    );

    if (isLandscape) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: 16),
            statsRow,
            const SizedBox(height: 24),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildEventCard(events[index]),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 16),
          statsRow,
          const SizedBox(height: 24),
          Expanded(child: _buildEventsList(events)),
        ],
      );
    }
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
              Icon(
                icon, size: 28, 
                color: Theme.of(context).colorScheme.primary
                ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyEventsScreen() {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        
        final header = Text(
          'My Events',
          style: TextStyle(
            fontFamily: 'Onest',
            fontSize: 24,
            color: Colors.grey[600]
          ),
        );

        final eventsStream = StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('events')
              .where('hostID', isEqualTo: widget.userId)
              .snapshots(),
          builder: (context, snapshot) {
            // Error handling
            if (snapshot.hasError) {
              return _buildErrorWidget('Error loading events');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final events = snapshot.data!.docs;
            
            // Sort events manually by datetime in descending order
            events.sort((a, b) {
              final dateA = (a.data() as Map<String, dynamic>)['datetime']?.toDate();
              final dateB = (b.data() as Map<String, dynamic>)['datetime']?.toDate();
              if (dateA == null && dateB == null) return 0;
              if (dateA == null) return 1;
              if (dateB == null) return -1;
              return dateB.compareTo(dateA);
            });

            if (events.isEmpty) {
              return _buildEmptyEventsWidget();
            }

            if (isLandscape) {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildEventCard(events[index]),
              );
            } else {
              return _buildEventsList(events);
            }
          },
        );

        // Landscape orientation support for My Events screen
        if (isLandscape) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header,
                const SizedBox(height: 16),
                eventsStream,
                const SizedBox(height: 20),
              ],
            ),
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 16),
              Expanded(child: eventsStream),
            ],
          );
        }
      },
    );
  }

  Widget _buildEventsList(List<QueryDocumentSnapshot> events) {
    return ListView.separated(
      itemCount: events.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildEventCard(events[index]),
    );
  }

  Widget _buildEventCard(QueryDocumentSnapshot eventDoc) {
    final event = eventDoc.data() as Map<String, dynamic>;
    final eventId = eventDoc.id;
    final dateTime = event['datetime']?.toDate();
    final isPastEvent = dateTime?.isBefore(DateTime.now()) ?? false;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailsScreen(
                eventId: eventId, 
                userId: widget.userId,
              ),
            ),
          );
        },
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
                          ? Colors.grey
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
                  // Calculate total tickets and checked-in tickets based on quantity
                  int totalTickets = 0;
                  int checkedInTickets = 0;

                  if (snapshot.hasData) {
                    for (var ticket in snapshot.data!.docs) {
                      final ticketData = ticket.data() as Map<String, dynamic>;
                      final quantity = ticketData['metadata']?['quantity'] ?? 1;
                      
                      totalTickets += quantity as int;
                      
                      if (ticketData['isCheckedIn'] == true) {
                        checkedInTickets += quantity;
                      }
                    }
                  }

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
    // Orientation support for Scan Tickets screen
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;

        final scanCard = Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Icon(Icons.qr_code_scanner,
                    size: 64, 
                    ),
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
        );

        final recentCheckInsHeader = const Text(
          'Recent Check-ins',
          style: TextStyle(
            fontFamily: 'Onest',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        );

        final checkInsList = FutureBuilder<List<QueryDocumentSnapshot>>(
          future: _getRecentCheckIns(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorWidget('Error loading check-ins');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final tickets = snapshot.data ?? [];

            if (tickets.isEmpty) {
              return const Center(
                child: Text(
                  'No recent check-ins',
                  style: TextStyle(fontFamily: 'Onest'),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: isLandscape,
              physics: isLandscape ? const NeverScrollableScrollPhysics() : null,
              itemCount: tickets.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final ticket = tickets[index].data() as Map<String, dynamic>;
                final quantity = ticket['metadata']?['quantity'] ?? 1;
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(Icons.person,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(
                    ticket['userID'] ?? 'Anonymous',
                    style: const TextStyle(fontFamily: 'Onest'),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Event: ${ticket['eventTitle'] ?? 'Unknown'}',
                        style: const TextStyle(fontFamily: 'Onest'),
                      ),
                      if (quantity > 1)
                        Text(
                          'Tickets: $quantity',
                          style: const TextStyle(
                            fontFamily: 'Onest',
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                    ],
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
        );

        // Center scan card in landscape mode
        if (isLandscape) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Center scan card in landscape
                Center(child: scanCard),
                const SizedBox(height: 24),
                recentCheckInsHeader,
                const SizedBox(height: 16),
                checkInsList,
                const SizedBox(height: 20),
              ],
            ),
          );
        } else {
          return Column(
            children: [
              scanCard,
              const SizedBox(height: 24),
              recentCheckInsHeader,
              const SizedBox(height: 16),
              Expanded(child: checkInsList),
            ],
          );
        }
      },
    );
  }

  // Helper method to get recent check-ins for this user's events
  Future<List<QueryDocumentSnapshot>> _getRecentCheckIns() async {
    try {
      // First, get all events created by this user
      final eventsQuery = await _firestore
          .collection('events')
          .where('hostID', isEqualTo: widget.userId)
          .get();
      
      if (eventsQuery.docs.isEmpty) {
        return [];
      }

      // Get event IDs
      final eventIds = eventsQuery.docs.map((doc) => doc.id).toList();

      // Get all checked-in tickets
      final ticketsQuery = await _firestore
          .collection('tickets')
          .where('isCheckedIn', isEqualTo: true)
          .get();

      // Filter tickets for this user's events and sort by check-in time
      final userTickets = ticketsQuery.docs.where((ticket) {
        final ticketData = ticket.data();
        return eventIds.contains(ticketData['eventID']);
      }).toList();

      // Sort by checkInTime (most recent first)
      userTickets.sort((a, b) {
        final timeA = (a.data())['checkInTime'];
        final timeB = (b.data())['checkInTime'];
        if (timeA == null && timeB == null) return 0;
        if (timeA == null) return 1;
        if (timeB == null) return -1;
        return (timeB as Timestamp).compareTo(timeA as Timestamp);
      });

      // Return the 10 most recent
      return userTickets.take(10).toList();
    } catch (e) {
      // Return empty list on error
      return [];
    }
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

  void _createNewEvent(BuildContext context) {
    context.pushNamed('addEvent', extra: widget.userId);
  }

  void _scanQRCode(BuildContext context) {
  // Navigate directly to QR scanner screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(userId: widget.userId),
      ),
    );
  }
}