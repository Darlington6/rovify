import 'package:rovify/domain/entities/nft.dart';

class NftModel extends Nft {
  NftModel({
    required super.id,
    required super.title,
    required super.imageUrl,
    required super.creatorName,
    required super.likes,
    required super.bids,
  });

  factory NftModel.fromMap(Map<String, dynamic> map, String docId) {
    return NftModel(
      id: docId,
      title: map['title'] ?? 'Untitled NFT',
      imageUrl: map['imageUrl'] ?? '',
      creatorName: map['creatorName'] ?? 'Unknown',
      likes: map['likes'] ?? '',
      bids: map['bids'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'creatorName': creatorName,
      'likes': likes,
      'bids': bids,
    };
  }

  Nft toEntity() => this;
  static NftModel fromEntity(Nft nft) => NftModel(
    id: nft.id,
    title: nft.title,
    imageUrl: nft.imageUrl,
    creatorName: nft.creatorName,
    likes: nft.likes,
    bids: nft.bids,
  );
}