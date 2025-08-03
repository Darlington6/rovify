import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rovify/data/models/nft_model.dart';

class NftRepository {
  final _nftRef = FirebaseFirestore.instance.collection('trending_nfts');

  Future<List<NftModel>> fetchTrendingNfts() async {
    final snapshot = await _nftRef.get();
    return snapshot.docs
        .map((doc) => NftModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}