import 'package:rovify/domain/entities/nft.dart';
import 'package:rovify/domain/repositories/nft_repository.dart';

class FetchTrendingNfts {
  final NftRepository repository;

  FetchTrendingNfts(this.repository);

  Future<List<Nft>> call() async {
    return await repository.fetchTrendingNfts();
  }
}