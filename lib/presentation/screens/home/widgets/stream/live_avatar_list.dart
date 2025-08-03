import 'package:flutter/material.dart';
import 'package:rovify/domain/entities/event.dart';

class LiveAvatarList extends StatelessWidget {
  final List<Event> liveEvents;

  const LiveAvatarList({super.key, required this.liveEvents});

  @override
  Widget build(BuildContext context) {
    // Group by unique hostName to avoid duplicate avatars
    final uniqueHosts = <String, Event>{};
    for (var event in liveEvents) {
      if (!uniqueHosts.containsKey(event.hostName)) {
        uniqueHosts[event.hostName] = event;
      }
    }

    final hosts = uniqueHosts.values.toList();

    return SizedBox(
      height: 85,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: hosts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final event = hosts[index];

          return GestureDetector(
            onTap: () {
              // Navigate to host's live stream
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Joining ${event.hostName}\'s live stream...'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    // Avatar with gradient border for live indicator
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Colors.red,
                            Colors.orange,
                            Colors.yellow,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: (event.hostImageUrl.isNotEmpty)
                              ? NetworkImage(event.hostImageUrl)
                              : null,
                          child: (event.hostImageUrl.isEmpty)
                              ? const Icon(Icons.person, size: 26, color: Colors.grey)
                              : null,
                          onBackgroundImageError: (_, __) {},
                        ),
                      ),
                    ),
                    // Live indicator badge
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 60, // Fixed width to prevent overflow
                  child: Text(
                    event.hostName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}