import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rovify/domain/entities/ticket.dart';

class TicketModel extends Ticket {
  const TicketModel({
    required super.id,
    required super.eventId,
    required super.userId,
    required super.walletAddress,
    required super.qrCodeUrl,
    required super.metadata,
    required super.checkedIn,
    required super.issuedAt,
  });

  factory TicketModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TicketModel(
      id: doc.id,
      eventId: data['eventID'] ?? '',
      userId: data['userID'] ?? '',
      walletAddress: data['walletAddress'] ?? '',
      qrCodeUrl: data['qrCodeUrl'] ?? '',
      metadata: data['metadata'] ?? {},
      checkedIn: data['checkedIn'] ?? false,
      issuedAt: (data['issuedAt'] as Timestamp).toDate(),
    );
  }
}