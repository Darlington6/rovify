import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rovify/data/models/nft_model.dart';

abstract class NftRemoteDataSource {
  Future<List<NftModel>> fetchTrendingNfts();
}

class NftRemoteDataSourceImpl implements NftRemoteDataSource {
  final FirebaseFirestore firestore;

  NftRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<NftModel>> fetchTrendingNfts() async {
    final snapshot = await firestore
        .collection('nfts')
        .orderBy('likes', descending: true)
        .limit(10)
        .get();

    return snapshot.docs
        .map((doc) => NftModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}