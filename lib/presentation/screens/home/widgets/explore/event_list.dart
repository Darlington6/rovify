import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rovify/presentation/screens/home/widgets/explore/event_card.dart';

class EventList extends StatelessWidget {
  final String searchQuery;
  final String categoryFilter;
  
  const EventList({
    super.key,
    required this.searchQuery,
    this.categoryFilter = 'popular',
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .where('status', isEqualTo: 'upcoming')
          .orderBy('datetime')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              searchQuery.isEmpty 
                ? 'No upcoming events'
                : 'No events match your search',
            ),
          );
        }

        final filteredEvents = _applyFilters(snapshot.data!.docs);

        if (filteredEvents.isEmpty) {
          return const Center(child: Text('No events match your filters'));
        }

        return ListView.separated(
          itemCount: filteredEvents.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final event = filteredEvents[index];
            final data = event.data() as Map<String, dynamic>;
            
            return EventCard(
              eventId: event.id,
              title: data['title'] ?? 'Untitled',
              thumbnailUrl: data['thumbnailUrl'] ?? '',
              dateTime: (data['datetime'] as Timestamp).toDate(),
              location: data['location'] ?? '',
              hostId: data['hostID'] ?? '',
              type: data['type'] ?? '',
              description: data['description'] ?? '',
              status: data['status'] ?? 'upcoming',
              ticketType: data['ticketType'] ?? '',
              category: data['category'] ?? '',
              price: _convertToDouble(data['price']),
            );
          },
        );
      },
    );
  }

  double _convertToDouble(dynamic price) {
    if (price == null) return 0.0;
    if (price is int) return price.toDouble();
    if (price is double) return price;
    if (price is String) return double.tryParse(price) ?? 0.0;
    return 0.0;
  }

  List<QueryDocumentSnapshot> _applyFilters(List<QueryDocumentSnapshot> events) {
    return events.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      
      // Category filter
      if (categoryFilter != 'popular' && 
          (data['category']?.toString().toLowerCase() != 
          categoryFilter.toLowerCase())) {
        return false;
      }
      
      // Search filter
      if (searchQuery.isNotEmpty) {
        final title = data['title']?.toString().toLowerCase() ?? '';
        final description = data['description']?.toString().toLowerCase() ?? '';
        final location = data['location']?.toString().toLowerCase() ?? '';
        final category = data['category']?.toString().toLowerCase() ?? '';

        return title.contains(searchQuery.toLowerCase()) ||
            description.contains(searchQuery.toLowerCase()) ||
            location.contains(searchQuery.toLowerCase()) ||
            category.contains(searchQuery.toLowerCase());
      }
      
      return true;
    }).toList();
  }
}