class Event {
  final String id;
  final String title;
  final String hostName;
  final String hostImageUrl;
  final String thumbnailUrl;
  final int viewers;
  final int followers;
  final bool isLive;
  final String? hostId;
  final String? category;
  final String? type;
  final String? location;
  final DateTime? datetime;
  final String? description;
  final String? status;
  final String? ticketType;
  final DateTime? createdAt;  

  Event({
    required this.id,
    required this.title,
    required this.hostName,
    required this.hostImageUrl,
    required this.thumbnailUrl,
    required this.viewers,
    required this.followers,
    required this.isLive,
    required this.hostId,
    required this.category,
    required this.type,
    required this.location, 
    required this.datetime, 
    required this.description, 
    required this.status, 
    required this.ticketType, 
    required this.createdAt,    
  });
}