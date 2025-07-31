class Event {
  final String id;
  final String title;
  final String hostId;
  final String type; // "virtual" | "in-person"
  final String location;
  final String category;
  final DateTime datetime;
  final String description;
  final String status; // "upcoming" | "live" | "ended"
  final String thumbnailUrl;
  final String ticketType;
  final DateTime createdAt;

  const Event({
    required this.id,
    required this.title,
    required this.hostId,
    required this.type,
    required this.location,
    required this.category,
    required this.datetime,
    required this.description,
    required this.status,
    required this.thumbnailUrl,
    required this.ticketType,
    required this.createdAt,
  });
}