class Ticket {
  final String id;
  final String eventId;
  final String userId;
  final String walletAddress;
  final String qrCodeUrl;
  final Map<String, dynamic> metadata;
  final bool checkedIn;
  final DateTime issuedAt;

  const Ticket({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.walletAddress,
    required this.qrCodeUrl,
    required this.metadata,
    required this.checkedIn,
    required this.issuedAt,
  });
}