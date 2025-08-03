import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRScannerScreen extends StatefulWidget {
  final String userId;
  
  const QRScannerScreen({super.key, required this.userId});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool isProcessing = false;
  bool _flashOn = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan Ticket',
          style: TextStyle(fontFamily: 'Onest', fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _flashOn ? Icons.flash_on : Icons.flash_off
            ),
            onPressed: () async {
              await cameraController.toggleTorch();
              setState(() {
                _flashOn = !_flashOn;
              });
            },
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isLandscape = orientation == Orientation.landscape;
          
          if (isLandscape) {
            // Landscape layout - side by side
            return Row(
              children: [
                // Camera view takes most of the space
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      MobileScanner(
                        controller: cameraController,
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                            if (barcode.rawValue != null && !isProcessing) {
                              _processScannedTicket(barcode.rawValue!);
                              break;
                            }
                          }
                        },
                      ),
                      // Custom overlay
                      Container(
                        decoration: ShapeDecoration(
                          shape: QrScannerOverlayShape(
                            borderColor: Theme.of(context).colorScheme.primary,
                            borderRadius: 10,
                            borderLength: 30,
                            borderWidth: 10,
                            cutOutSize: MediaQuery.of(context).size.height * 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Instructions panel
                Container(
                  width: 200,
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isProcessing)
                        const Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8),
                            Text(
                              'Processing ticket...',
                              style: TextStyle(fontFamily: 'Onest'),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      else
                        const Column(
                          children: [
                            Icon(Icons.qr_code_scanner, size: 32, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'Point camera at ticket QR code',
                              style: TextStyle(
                                fontFamily: 'Onest',
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // Portrait layout - stacked
            return Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Stack(
                    children: [
                      MobileScanner(
                        controller: cameraController,
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                            if (barcode.rawValue != null && !isProcessing) {
                              _processScannedTicket(barcode.rawValue!);
                              break;
                            }
                          }
                        },
                      ),
                      // Custom overlay
                      Container(
                        decoration: ShapeDecoration(
                          shape: QrScannerOverlayShape(
                            borderColor: Theme.of(context).colorScheme.primary,
                            borderRadius: 10,
                            borderLength: 30,
                            borderWidth: 10,
                            cutOutSize: MediaQuery.of(context).size.width * 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.surface,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isProcessing)
                          const Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 8),
                              Text(
                                'Processing ticket...',
                                style: TextStyle(fontFamily: 'Onest'),
                              ),
                            ],
                          )
                        else
                          const Column(
                            children: [
                              Icon(Icons.qr_code_scanner, size: 32, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'Point camera at ticket QR code',
                                style: TextStyle(
                                  fontFamily: 'Onest',
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<void> _processScannedTicket(String qrData) async {
    if (isProcessing) return;
    
    setState(() {
      isProcessing = true;
    });

    // Pause scanning while processing
    await cameraController.stop();

    try {
      // Parse the QR code data
      final ticketId = _parseTicketId(qrData);
      
      if (ticketId == null) {
        _showErrorDialog('Invalid QR code format');
        return;
      }

      // Check if ticket exists and get ticket data
      DocumentSnapshot ticketDoc;
      try {
        ticketDoc = await _firestore.collection('tickets').doc(ticketId).get();
      } catch (e) {
        // Handle permission denied or other Firebase errors
        if (e.toString().contains('permission-denied') || 
            e.toString().contains('not-found') ||
            e.toString().contains('invalid-argument')) {
          _showErrorDialog('Ticket not found or invalid');
          return;
        }
        rethrow; // Re-throw other unexpected errors
      }
      
      if (!ticketDoc.exists) {
        _showErrorDialog('Ticket not found');
        return;
      }

      final ticketData = ticketDoc.data() as Map<String, dynamic>?;
      if (ticketData == null) {
        _showErrorDialog('Invalid ticket data');
        return;
      }

      final eventId = ticketData['eventID'];
      if (eventId == null) {
        _showErrorDialog('Ticket is not associated with any event');
        return;
      }
      
      // Verify this is the creator's event
      DocumentSnapshot eventDoc;
      try {
        eventDoc = await _firestore.collection('events').doc(eventId).get();
      } catch (e) {
        // Handle permission denied or other Firebase errors for events
        if (e.toString().contains('permission-denied') || 
            e.toString().contains('not-found')) {
          _showErrorDialog('Event not found or you are not authorized to access this event');
          return;
        }
        rethrow;
      }
      
      if (!eventDoc.exists) {
        _showErrorDialog('Event not found');
        return;
      }

      final eventData = eventDoc.data() as Map<String, dynamic>?;
      if (eventData == null || eventData['hostID'] != widget.userId) {
        _showErrorDialog('You are not authorized to check in tickets for this event');
        return;
      }

      // Check if already checked in
      if (ticketData['isCheckedIn'] == true) {
        _showInfoDialog('Ticket already checked in', isWarning: true);
        return;
      }

      // Update ticket as checked in
      try {
        await _firestore.collection('tickets').doc(ticketId).update({
          'isCheckedIn': true,
          'checkInTime': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        if (e.toString().contains('permission-denied')) {
          _showErrorDialog('You do not have permission to check in this ticket');
          return;
        }
        rethrow;
      }

      // Get event title for display
      final eventTitle = eventData['title'] ?? 'Unknown Event';
      final attendeeName = ticketData['userID'] ?? 'Anonymous';
      final quantity = ticketData['metadata']?['quantity'] ?? 1;

      _showSuccessDialog(attendeeName, eventTitle, quantity);

    } catch (e) {
      // Catch any remaining unexpected errors
      _showErrorDialog('An unexpected error occurred. Please try again.');
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  String? _parseTicketId(String qrData) {
    try {
      // If URL (from qrCodeUrl), extract the ticket ID from the end
      if (qrData.startsWith('http')) {
        final uri = Uri.parse(qrData);
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          return pathSegments.last;
        }
      }
      
      // Target just the ticket ID directly
      if (qrData.isNotEmpty) {
        return qrData.trim();
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  void _showSuccessDialog(String attendeeName, String eventTitle, int quantity) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text(
              'Check-in Successful!',
              style: TextStyle(fontFamily: 'Onest', fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendee: $attendeeName',
              style: const TextStyle(fontFamily: 'Onest', fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Event: $eventTitle',
              style: const TextStyle(fontFamily: 'Onest'),
            ),
            if (quantity > 1) ...[
              const SizedBox(height: 4),
              Text(
                'Tickets: $quantity',
                style: const TextStyle(
                  fontFamily: 'Onest',
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Resume scanning
              _resumeScanning();
            },
            child: const Text(
              'Continue Scanning',
              style: TextStyle(fontFamily: 'Onest'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to dashboard
            },
            child: const Text(
              'Done',
              style: TextStyle(fontFamily: 'Onest'),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text(
              'Error',
              style: TextStyle(fontFamily: 'Onest'),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Onest'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resumeScanning();
            },
            child: const Text(
              'Try Again',
              style: TextStyle(fontFamily: 'Onest'),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String message, {bool isWarning = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isWarning ? Icons.warning : Icons.info,
              color: isWarning ? Colors.orange : Colors.blue,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              isWarning ? 'Warning' : 'Info',
              style: const TextStyle(fontFamily: 'Onest'),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Onest'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resumeScanning();
            },
            child: const Text(
              'Continue',
              style: TextStyle(fontFamily: 'Onest'),
            ),
          ),
        ],
      ),
    );
  }

  void _resumeScanning() {
    if (mounted) {
      cameraController.start();
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

// Custom overlay shape class
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path path = Path()..addRect(rect);
    Path oval = Path()..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: rect.center,
          width: cutOutSize,
          height: cutOutSize,
        ),
        Radius.circular(borderRadius)));
    return Path.combine(PathOperation.difference, path, oval);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final mBorderLength = borderLength > cutOutSize / 2 + borderWidth * 2
        ? borderWidthSize / 2
        : borderLength;
    final mCutOutSize = cutOutSize < width ? cutOutSize : width - borderOffset;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - mCutOutSize / 2 + borderOffset,
      rect.top + height / 2 - mCutOutSize / 2 + borderOffset,
      mCutOutSize - borderOffset * 2,
      mCutOutSize - borderOffset * 2,
    );

    canvas
      ..saveLayer(
        rect,
        backgroundPaint,
      )
      ..drawRect(rect, backgroundPaint)
      ..drawRRect(
          RRect.fromRectAndRadius(
            cutOutRect,
            Radius.circular(borderRadius),
          ),
          boxPaint);

    canvas.restore();

    // Draw corner lines
    final lineLength = mBorderLength;
    final cornerOffset = borderOffset;

    // Top left corner
    canvas.drawPath(
        Path()
          ..moveTo(cutOutRect.left - cornerOffset, cutOutRect.top + lineLength)
          ..lineTo(cutOutRect.left - cornerOffset, cutOutRect.top + cornerOffset)
          ..lineTo(cutOutRect.left + lineLength, cutOutRect.top + cornerOffset),
        borderPaint);

    // Top right corner
    canvas.drawPath(
        Path()
          ..moveTo(cutOutRect.right - lineLength, cutOutRect.top + cornerOffset)
          ..lineTo(cutOutRect.right + cornerOffset, cutOutRect.top + cornerOffset)
          ..lineTo(cutOutRect.right + cornerOffset, cutOutRect.top + lineLength),
        borderPaint);

    // Bottom right corner
    canvas.drawPath(
        Path()
          ..moveTo(cutOutRect.right + cornerOffset, cutOutRect.bottom - lineLength)
          ..lineTo(cutOutRect.right + cornerOffset, cutOutRect.bottom - cornerOffset)
          ..lineTo(cutOutRect.right - lineLength, cutOutRect.bottom - cornerOffset),
        borderPaint);

    // Bottom left corner
    canvas.drawPath(
        Path()
          ..moveTo(cutOutRect.left + lineLength, cutOutRect.bottom - cornerOffset)
          ..lineTo(cutOutRect.left - cornerOffset, cutOutRect.bottom - cornerOffset)
          ..lineTo(cutOutRect.left - cornerOffset, cutOutRect.bottom - lineLength),
        borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}