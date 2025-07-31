import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  final String title;
  final String thumbnailUrl;
  final DateTime dateTime;
  final String location;
  final String hostId;
  final String category;
  final String type;
  final String description;
  final String status;
  final String ticketType;
  final String? hostName;
  final  price;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
    required this.title,
    required this.thumbnailUrl,
    required this.dateTime,
    required this.location,
    required this.hostId,
    required this.category,
    required this.type,
    required this.description,
    required this.status,
    required this.ticketType,
    this.hostName,
    required this.price,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  int _ticketCount = 1;
  bool _isBooking = false;
  String? _walletAddress;
  bool _loadingUserData = true;
  bool _paymentProcessing = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          setState(() {
            _walletAddress = userDoc['walletAddress'];
            _loadingUserData = false;
          });
        } else {
          setState(() => _loadingUserData = false);
        }
      } else {
        setState(() => _loadingUserData = false);
      }
    } catch (e) {
      setState(() => _loadingUserData = false);
      _showErrorSnackbar('Error loading user data: $e');
    }
  }

  Future<String> _generateQRCode(String ticketId) async {
    // In production, generate this on your backend with security features
    return 'https://api.qrserver.com/v1/create-qr-code/?size=500x500&data=${Uri.encodeComponent(ticketId)}';
  }

  Future<bool> _processPayment(double amount) async {
    setState(() => _paymentProcessing = true);
    try {
      // Simulate payment processing - replace with actual payment gateway integration
      await Future.delayed(const Duration(seconds: 2));
      return true;
    } catch (e) {
      _showErrorSnackbar('Payment failed: $e');
      return false;
    } finally {
      setState(() => _paymentProcessing = false);
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _bookEvent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorSnackbar('Please sign in to book tickets');
      return;
    }

    if (_walletAddress == null || _walletAddress!.isEmpty) {
      _showErrorSnackbar('Please set up your wallet address in profile settings');
      return;
    }

    setState(() => _isBooking = true);

    try {
      final totalPrice = widget.price * _ticketCount;

      // Step 1: Process payment
      final paymentSuccess = await _processPayment(totalPrice);
      if (!paymentSuccess) {
        throw Exception('Payment processing failed');
      }

      // Step 2: Generate ticket ID and QR code
      final ticketId = 'TKT-${DateTime.now().millisecondsSinceEpoch}';
      final qrCodeUrl = await _generateQRCode(ticketId);

      // Step 3: Create ticket document
      final ticketData = {
        'eventID': widget.eventId,
        'userID': user.uid,
        'walletAddress': _walletAddress,
        'qrCodeUrl': qrCodeUrl,
        'metadata': {
          'ticketType': widget.ticketType,
          'quantity': _ticketCount,
          'totalPaid': totalPrice,
          'eventTitle': widget.title,
          'eventDate': widget.dateTime,
          'eventLocation': widget.location,
          'eventImage': widget.thumbnailUrl,
          'perks': _getTicketPerks(widget.ticketType),
        },
        'isCheckedIn': false,
        'issuedAt': FieldValue.serverTimestamp(),
        'checkInTime': null,
      };

      // Transaction ensures both writes succeed or fail together
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Create ticket
        final ticketRef = FirebaseFirestore.instance.collection('tickets').doc(ticketId);
        transaction.set(ticketRef, ticketData);

        // Update event's tickets count
        final eventRef = FirebaseFirestore.instance.collection('events').doc(widget.eventId);
        transaction.update(eventRef, {
          'ticketsSold': FieldValue.increment(_ticketCount),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      // Step 4: Navigate to confirmation
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketConfirmationScreen(
              ticketId: ticketId,
              eventTitle: widget.title,
              dateTime: widget.dateTime,
              location: widget.location,
              qrCodeUrl: qrCodeUrl,
              ticketType: widget.ticketType,
              quantity: _ticketCount,
              totalPrice: totalPrice,
              thumbnailUrl: widget.thumbnailUrl,
            ),
          ),
        );
      }

      _showSuccessSnackbar('Ticket booked successfully!');
    } catch (e) {
      _showErrorSnackbar('Failed to book ticket: $e');
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }

  List<String> _getTicketPerks(String type) {
    switch (type) {
      case 'VIP':
        return ['Priority Access', 'Backstage Pass', 'Free Merchandise'];
      case 'Premium':
        return ['Early Entry', 'Reserved Seating'];
      default:
        return ['General Admission'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, MMMM d, y').format(widget.dateTime);
    final formattedTime = DateFormat('h:mm a').format(widget.dateTime);
    final totalPrice = widget.price * _ticketCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          if (widget.hostId == FirebaseAuth.instance.currentUser?.uid)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _navigateToEditEvent(),
            ),
        ],
      ),
      body: _loadingUserData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Image
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(widget.thumbnailUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Event Details
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Onest',
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Date and Time
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              '$formattedDate at $formattedTime',
                              style: const TextStyle(fontSize: 16, fontFamily: 'Onest'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Location
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              widget.location,
                              style: const TextStyle(fontSize: 16, fontFamily: 'Onest'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Host
                        Row(
                          children: [
                            const Icon(Icons.person, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Hosted by ${widget.hostName ?? "Unknown"}',
                              style: const TextStyle(fontSize: 16, fontFamily: 'Onest'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Description
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Onest',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.description,
                          style: const TextStyle(fontSize: 16, fontFamily: 'Onest'),
                        ),
                        const SizedBox(height: 24),

                        // Ticket Information
                        const Text(
                          'Ticket Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Onest',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${widget.ticketType} Ticket',
                              style: const TextStyle(fontSize: 16, fontFamily: 'Onest'),
                            ),
                            Text(
                              'Kes ${widget.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Onest',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Ticket Counter
                        Row(
                          children: [
                            const Text('Quantity:', style: TextStyle(fontSize: 16)),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                if (_ticketCount > 1) {
                                  setState(() => _ticketCount--);
                                }
                              },
                            ),
                            Text('$_ticketCount', style: const TextStyle(fontSize: 18)),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() => _ticketCount++);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Payment Method
                        if (_walletAddress != null) ...[
                          const Text(
                            'Payment Method',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Onest',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.account_balance_wallet),
                              const SizedBox(width: 8),
                              Text(
                                'Wallet: ${_walletAddress!.substring(0, 6)}...${_walletAddress!.substring(_walletAddress!.length - 4)}',
                                style: const TextStyle(fontFamily: 'Onest'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Total Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Onest',
                              ),
                            ),
                            Text(
                              'Kes ${totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontFamily: 'Onest',
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Book Now Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: (_isBooking || _paymentProcessing) ? null : _bookEvent,
                            child: (_isBooking || _paymentProcessing)
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'BOOK NOW',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.bold,
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

  void _navigateToEditEvent() {
    // Implement navigation to edit event screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEventScreen(
          eventId: widget.eventId,
          initialTitle: widget.title,
          initialDescription: widget.description,
          initialLocation: widget.location,
          initialDateTime: widget.dateTime,
          initialThumbnailUrl: widget.thumbnailUrl,
          initialCategory: widget.category,
          initialType: widget.type,
          initialTicketType: widget.ticketType,
          initialPrice: widget.price,
        ),
      ),
    );
  }
}

class TicketConfirmationScreen extends StatelessWidget {
  final String ticketId;
  final String eventTitle;
  final DateTime dateTime;
  final String location;
  final String qrCodeUrl;
  final String ticketType;
  final int quantity;
  final  totalPrice;
  final String thumbnailUrl;

  const TicketConfirmationScreen({
    super.key,
    required this.ticketId,
    required this.eventTitle,
    required this.dateTime,
    required this.location,
    required this.qrCodeUrl,
    required this.ticketType,
    required this.quantity,
    required this.totalPrice,
    required this.thumbnailUrl,
  });

  // Future<void> _shareTicket(BuildContext context) async {
  //   try {
  //     // In a real app, you would generate a shareable image or PDF
  //     final text = '''
  //     🎟️ Your Ticket 🎟️
      
  //     Event: $eventTitle
  //     Date: ${DateFormat('EEEE, MMMM d, y').format(dateTime)}
  //     Location: $location
  //     Ticket ID: $ticketId
  //     Type: $ticketType
  //     Quantity: $quantity
  //     Total: Kes ${totalPrice.toStringAsFixed(2)}
      
  //     Show this QR code at the entrance:
  //     $qrCodeUrl
  //     ''';

  //     await Share.share(text);
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error sharing ticket: $e')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Confirmation'),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.share),
          //   onPressed: () => _shareTicket(context),
          // ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Event Image
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(thumbnailUrl),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 24),

            // Confirmation Message
            Text(
              'Your ticket is confirmed!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Show this at the entrance',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // QR Code
            // Container(
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     border: Border.all(color: Colors.grey.shade300),
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: QrImageView(
            //     data: ticketId,
            //     version: QrVersions.auto,
            //     size: 200,
            //     foregroundColor: Colors.black,
            //   ),
            // ),
            const SizedBox(height: 16),
            Text(
              'Scan this QR code',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Ticket Details
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
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('EEEE, MMMM d, y • h:mm a').format(dateTime),
                    style: const TextStyle(fontFamily: 'Onest'),
                  ),
                  Text(
                    location,
                    style: const TextStyle(fontFamily: 'Onest'),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$ticketType Ticket',
                        style: const TextStyle(fontFamily: 'Onest'),
                      ),
                      Text(
                        'x$quantity',
                        style: const TextStyle(fontFamily: 'Onest'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Paid:',
                        style: TextStyle(
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Kes ${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // View Ticket Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to full ticket view
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'VIEW TICKET DETAILS',
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
    );
  }
}

// Placeholder for edit event screen - implement as needed
class EditEventScreen extends StatelessWidget {
  final String eventId;
  final String initialTitle;
  final String initialDescription;
  final String initialLocation;
  final DateTime initialDateTime;
  final String initialThumbnailUrl;
  final String initialCategory;
  final String initialType;
  final String initialTicketType;
  final initialPrice;

  const EditEventScreen({
    super.key,
    required this.eventId,
    required this.initialTitle,
    required this.initialDescription,
    required this.initialLocation,
    required this.initialDateTime,
    required this.initialThumbnailUrl,
    required this.initialCategory,
    required this.initialType,
    required this.initialTicketType,
    required this.initialPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Event')),
      body: const Center(child: Text('Edit Event Form Implementation')),
    );
  }
}