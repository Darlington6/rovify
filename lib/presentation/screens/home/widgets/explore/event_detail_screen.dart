import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rovify/presentation/common/common_appbar.dart';
import 'package:rovify/presentation/screens/home/widgets/creator/edit_event_screen.dart';

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
  final double price;

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
    required this.price, required String userId,
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final bool _checkingAvailability = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Safe wallet display method
  String _getWalletDisplayText(String? walletAddress) {
    if (walletAddress == null || walletAddress.isEmpty) {
      return 'Wallet: Not set';
    }
    
    if (walletAddress.length <= 10) {
      // If wallet address is too short, show it as is
      return 'Wallet: $walletAddress';
    }
    
    // Safe substring for longer addresses
    final start = walletAddress.substring(0, 6);
    final end = walletAddress.substring(walletAddress.length - 4);
    return 'Wallet: $start...$end';
  }

  Future<void> _fetchUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        
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

  Future<void> _navigateToEditEvent() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Fetch complete event data from Firestore
      final eventDoc = await _firestore.collection('events').doc(widget.eventId).get();
      
      // Hide loading indicator
      if (mounted) Navigator.pop(context);
      
      if (!eventDoc.exists) {
        _showErrorSnackbar('Event not found');
        return;
      }

      final eventData = eventDoc.data()!;
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditEventScreen(
              eventId: widget.eventId,
              eventData: {
                'title': eventData['title'] ?? widget.title,
                'description': eventData['description'] ?? widget.description,
                'location': eventData['location'] ?? widget.location,
                'datetime': eventData['datetime'] ?? Timestamp.fromDate(widget.dateTime),
                'category': eventData['category'] ?? widget.category,
                'type': eventData['type'] ?? widget.type,
                'price': eventData['price'] ?? widget.price,
                'totalTickets': eventData['totalTickets'],
              },
              userId: FirebaseAuth.instance.currentUser?.uid ?? '',
            ),
          ),
        );
      }
    } catch (e) {
      // Hide loading indicator if still showing
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showErrorSnackbar('Failed to load event data: ${e.toString()}');
      debugPrint('Error fetching event data: $e');
    }
  }

  Future<String> _generateQRCode(String ticketId) async {
    return 'https://api.qrserver.com/v1/create-qr-code/?size=500x500&data=${Uri.encodeComponent(ticketId)}';
  }

  Future<bool> _processPayment(double amount) async {
    setState(() => _paymentProcessing = true);
    try {
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
    final user = _auth.currentUser;
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
      // Check ticket availability
      final eventDoc = await _firestore.collection('events').doc(widget.eventId).get();
      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      final totalTickets = eventDoc.data()?['totalTickets'] as int?;
      final ticketsSold = eventDoc.data()?['ticketsSold'] as int? ?? 0;

      final remainingTickets = (totalTickets ?? 0) - ticketsSold;
      final verb = remainingTickets == 1 ? 'is' : 'are';
      final ticketWord = remainingTickets == 1 ? 'ticket' : 'tickets';

      // Check for zero availability
      if (remainingTickets <= 0) {
        throw Exception('Sorry, this event is sold out. No ticket(s) available.');
      }

      // Check for overbooking circumstances (when tickets are limited)
      if (totalTickets != null && (ticketsSold + _ticketCount) > totalTickets) {
        throw Exception('Oops! There $verb only $remainingTickets $ticketWord left. You cannot book $_ticketCount.');
      }

      final totalPrice = widget.price * _ticketCount;

      // Process payment
      final paymentSuccess = await _processPayment(totalPrice);
      if (!paymentSuccess) {
        throw Exception('Payment processing failed');
      }

      // Get event host ID
      final eventHostId = eventDoc['hostID'];

      final ticketId = 'TKT-${DateTime.now().millisecondsSinceEpoch}';
      final qrCodeUrl = await _generateQRCode(ticketId);

      // Prepare ticket data
      final ticketData = {
        'eventID': widget.eventId,
        'userID': user.uid,
        'eventHostId': eventHostId,
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

      // Create ticket document
      await _firestore.collection('tickets').doc(ticketId).set(ticketData);

      // Update event ticket count
      await _firestore.collection('events').doc(widget.eventId).update({
        'ticketsSold': FieldValue.increment(_ticketCount),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // CREATE NOTIFICATION HERE
      await NotificationService.createTicketBookingNotification(
        userId: user.uid,
        eventTitle: widget.title,
        ticketId: ticketId,
        quantity: _ticketCount,
        totalPrice: totalPrice,
      );

      // Navigate to confirmation
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
      _showErrorSnackbar(e.toString());
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
        centerTitle: true,
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

                        // Payment Method - Using safe wallet display
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
                              _getWalletDisplayText(_walletAddress),
                              style: const TextStyle(fontFamily: 'Onest'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

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
                              backgroundColor: Color(0xFF000000),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: (_isBooking || _paymentProcessing || _checkingAvailability) 
                              ? null 
                              : _bookEvent,
                            child: (_isBooking || _paymentProcessing || _checkingAvailability)
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                'Book Now',
                                style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.bold,
                                    ),
                                ),
                              ),
                          ),
                          const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
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
  final double totalPrice;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Confirmation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
            Text(
              'Your ticket is confirmed!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge,
                  children: [
                    const TextSpan(text: "Check "),
                    const TextSpan(
                      text: "'My Tickets'",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: " in the profile drawer "),
                    const TextSpan(text: "or "),
                    const TextSpan(
                      text: "'View Details'",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'The host will scan the QR code to check you in',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 24),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Color(0xFF000000),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Onest',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}