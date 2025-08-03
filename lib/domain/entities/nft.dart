class Nft {
  final String id;
  final String title;
  final String imageUrl;
  final String creatorName;
  final int likes;
  final int bids;

  Nft({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.creatorName,
    required this.likes,
    required this.bids,
  });
}