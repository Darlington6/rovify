import 'package:rovify/data/datasources/nft_remote_datasource.dart';
import 'package:rovify/domain/entities/nft.dart';

abstract class NftRepository {
  Future<List<Nft>> fetchTrendingNfts();
}

class NftRepositoryImpl implements NftRepository {
  final NftRemoteDataSource remoteDataSource;

  NftRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Nft>> fetchTrendingNfts() async {
    final models = await remoteDataSource.fetchTrendingNfts();
    return models.map((e) => e.toEntity()).toList();
  }
}