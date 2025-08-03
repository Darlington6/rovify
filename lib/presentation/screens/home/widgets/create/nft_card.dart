import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NftCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String creatorName;
  final int likes;
  final int bids;

  const NftCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.creatorName,
    required this.likes,
    required this.bids,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              height: 120,
              width: 160,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '$creatorName • ${NumberFormat.compact().format(likes)} likes',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            '${NumberFormat.compact().format(bids)} bids',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}