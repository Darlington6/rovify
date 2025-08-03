import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/stream/event_card.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Live Events"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .where('isLive', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Text("Something went wrong");
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!.docs;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: events.map((doc) {
                final data = doc.data() as Map<String, dynamic>;

                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: EventCard(
                    title: data['title'] ?? '',
                    thumbnailUrl: data['thumbnailUrl'] ?? '',
                    hostName: data['hostName'] ?? '',
                    followers: data['followers'] ?? 0,
                    viewers: (data['liveViewers'] / 1000).round(),
                    isLive: data['isLive'] ?? false, 
                    hostImageUrl: '', 
                    hostId: '',
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}