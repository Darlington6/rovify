import 'package:flutter/material.dart';

class NFTDetailScreen extends StatelessWidget {
  final String title;
  final String creatorName;
  final String price;
  final String image;
  final String profileImage;

  const NFTDetailScreen({
    super.key,
    required this.title,
    required this.creatorName,
    required this.price,
    required this.image,
    required this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFT Details'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (image.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(image),
              ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(profileImage),
                ),
                const SizedBox(width: 8),
                Text("Created by $creatorName", style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Text("Price: $price", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Place a Bid"),
            )
          ],
        ),
      ),
    );
  }
}
