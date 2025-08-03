import 'package:rovify/data/models/nft_model.dart';

abstract class TrendingNftState {}

class TrendingNftInitial extends TrendingNftState {}

class TrendingNftLoading extends TrendingNftState {}

class TrendingNftLoaded extends TrendingNftState {
  final List<NftModel> nfts;

  TrendingNftLoaded(this.nfts);
}

class TrendingNftError extends TrendingNftState {
  final String message;

  TrendingNftError(this.message);
}