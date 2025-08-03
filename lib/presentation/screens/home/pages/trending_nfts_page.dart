import 'package:flutter/material.dart';
import 'package:rovify/domain/entities/nft.dart';
import 'package:rovify/domain/usecases/fetch_nfts.dart';
import 'package:rovify/presentation/screens/home/widgets/create/nft_card.dart';

class TrendingNftsPage extends StatelessWidget {
  final FetchTrendingNfts fetchTrendingNfts;

  const TrendingNftsPage({super.key, required this.fetchTrendingNfts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set a white background
      appBar: AppBar(
        title: const Text("Trending NFTs"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Nft>>(
        future: fetchTrendingNfts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading NFTs"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final nfts = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: nfts.map((nft) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: NftCard(
                  title: nft.title,
                  imageUrl: nft.imageUrl,
                  creatorName: nft.creatorName,
                  likes: nft.likes,
                  bids: nft.bids,
                ),
              )).toList(),
            ),
          );
        },
      ),
    );
  }
}