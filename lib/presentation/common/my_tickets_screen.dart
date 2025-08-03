import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Tickets'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('Please sign in to view your tickets'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tickets'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .where('userID', isEqualTo: user.uid)
            .orderBy('issuedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading tickets: ${snapshot.error}'),
            );
          }

          final tickets = snapshot.data?.docs ?? [];

          if (tickets.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'You do not currently have any tickets. All your tickets for events will appear here...',
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
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              final ticketData = ticket.data() as Map<String, dynamic>;
              final metadata = ticketData['metadata'] as Map<String, dynamic>? ?? {};
              
              final eventTitle = metadata['eventTitle'] ?? 'Unknown Event';
              final eventDate = metadata['eventDate'];
              final eventLocation = metadata['eventLocation'] ?? 'Unknown Location';
              final ticketType = metadata['ticketType'] ?? 'General';
              final quantity = metadata['quantity'] ?? 1;
              final totalPaid = metadata['totalPaid'] ?? 0.0;
              final eventImage = metadata['eventImage'] ?? '';
              
              // Parse event date
              DateTime? parsedDate;
              if (eventDate is Timestamp) {
                parsedDate = eventDate.toDate();
              } else if (eventDate is DateTime) {
                parsedDate = eventDate;
              }
              
              final isUpcoming = parsedDate?.isAfter(DateTime.now()) ?? false;
              final dateText = parsedDate != null 
                  ? DateFormat('MMM d, y • h:mm a').format(parsedDate)
                  : 'Date not available';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TicketDetailsScreen(
                          ticketId: ticket.id,
                          ticketData: ticketData,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Image
                      if (eventImage.isNotEmpty)
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(eventImage),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      
                      // Ticket Details
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Event Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isUpcoming ? Colors.green : Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isUpcoming ? 'UPCOMING' : 'PAST',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Onest',
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Event Title
                            Text(
                              eventTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Onest',
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            
                            // Date and Location
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    dateText,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontFamily: 'Onest',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    eventLocation,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontFamily: 'Onest',
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            // Ticket Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$ticketType Ticket × $quantity',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Onest',
                                  ),
                                ),
                                Text(
                                  'Kes ${totalPaid.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                    fontFamily: 'Onest',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TicketDetailsScreen extends StatelessWidget {
  final String ticketId;
  final Map<String, dynamic> ticketData;

  const TicketDetailsScreen({
    super.key,
    required this.ticketId,
    required this.ticketData,
  });

  @override
  Widget build(BuildContext context) {
    final metadata = ticketData['metadata'] as Map<String, dynamic>? ?? {};
    final eventTitle = metadata['eventTitle'] ?? 'Unknown Event';
    final eventDate = metadata['eventDate'];
    final eventLocation = metadata['eventLocation'] ?? 'Unknown Location';
    final ticketType = metadata['ticketType'] ?? 'General';
    final quantity = metadata['quantity'] ?? 1;
    final totalPaid = metadata['totalPaid'] ?? 0.0;
    final eventImage = metadata['eventImage'] ?? '';
    final qrCodeUrl = ticketData['qrCodeUrl'] ?? '';
    final isCheckedIn = ticketData['isCheckedIn'] ?? false;
    
    // Parse event date
    DateTime? parsedDate;
    if (eventDate is Timestamp) {
      parsedDate = eventDate.toDate();
    } else if (eventDate is DateTime) {
      parsedDate = eventDate;
    }
    
    final dateText = parsedDate != null 
        ? DateFormat('EEEE, MMMM d, y • h:mm a').format(parsedDate)
        : 'Date not available';

    // Get user data for ticket holder name
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Event Image
            if (eventImage.isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(eventImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // QR Code
                  if (qrCodeUrl.isNotEmpty)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Image.network(
                              qrCodeUrl,
                              width: 200,
                              height: 200,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 200,
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.qr_code, size: 100),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ticket ID: $ticketId',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontFamily: 'Onest',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Check-in Status
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCheckedIn ? Colors.green.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCheckedIn ? Colors.green : Colors.orange,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCheckedIn ? Icons.check_circle : Icons.pending,
                          color: isCheckedIn ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isCheckedIn ? 'Checked In' : 'Not Checked In',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCheckedIn ? Colors.green : Colors.orange,
                            fontFamily: 'Onest',
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Ticket Information Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eventTitle,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Onest',
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        _buildInfoRow(Icons.calendar_today, 'Date & Time', dateText),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.location_on, 'Location', eventLocation),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.confirmation_number, 'Ticket Type', ticketType),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.numbers, 'Quantity', quantity.toString()),
                        
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        
                        // Ticket Holder Info
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(ticketData['userID'])
                              .get(),
                          builder: (context, snapshot) {
                            final userData = snapshot.data?.data() as Map<String, dynamic>?;
                            final holderName = userData?['displayName'] ?? 'Unknown';
                            final holderEmail = userData?['email'] ?? '';
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ticket Holder',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Onest',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  holderName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Onest',
                                  ),
                                ),
                                if (holderEmail.isNotEmpty)
                                  Text(
                                    holderEmail,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontFamily: 'Onest',
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 8),
                              ],
                            );
                          },
                        ),
                        
                        // Total Paid
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Paid:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Onest',
                              ),
                            ),
                            Text(
                              'Kes ${totalPaid.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                                fontFamily: 'Onest',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF000000),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Onest',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: 'Onest',
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Onest',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}