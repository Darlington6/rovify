import 'package:flutter/material.dart';
import 'event_card.dart';

class EventGrid extends StatelessWidget {
  final List<Map<String, dynamic>> events;

  const EventGrid({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final crossAxisCount = orientation == Orientation.portrait ? 2 : 4;
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        children: _buildRows(context, crossAxisCount),
      ),
    );
  }

  List<Widget> _buildRows(BuildContext context, int crossAxisCount) {
    List<Widget> rows = [];
    
    for (int i = 0; i < events.length; i += crossAxisCount) {
      List<Widget> rowChildren = [];
      
      for (int j = 0; j < crossAxisCount && (i + j) < events.length; j++) {
        final event = events[i + j];
        rowChildren.add(
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: j < crossAxisCount - 1 ? 12 : 0,
              ),
              child: EventCard(
                title: event['title'],
                thumbnailUrl: event['thumbnailUrl'],
                hostName: event['hostName'],
                hostImageUrl: event['hostImageUrl'],
                followers: event['followers'],
                viewers: event['viewers'],
                isLive: event['isLive'], 
                hostId: '',
              ),
            ),
          ),
        );
      }
      
      // Fill remaining space if last row has fewer items
      while (rowChildren.length < crossAxisCount) {
        rowChildren.add(const Expanded(child: SizedBox()));
      }
      
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowChildren,
        ),
      );
      
      // Add spacing between rows (except for the last row)
      if (i + crossAxisCount < events.length) {
        rows.add(const SizedBox(height: 16));
      }
    }
    
    return rows;
  }
}