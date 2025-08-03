import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rovify/domain/repositories/nft_repository.dart';
import 'package:rovify/presentation/blocs/nft/nft_event.dart';
import 'package:rovify/presentation/blocs/nft/nft_state.dart';

class TrendingNftBloc extends Bloc<TrendingNftEvent, TrendingNftState> {
  final NftRepository nftRepository;

  TrendingNftBloc({required this.nftRepository}) : super(TrendingNftInitial()) {
    on<FetchTrendingNftsRequested>(_onFetchTrendingNfts);
  }

  void _onFetchTrendingNfts(
      FetchTrendingNftsRequested event, Emitter<TrendingNftState> emit) async {
    emit(TrendingNftLoading());
    try {
      final nfts = await nftRepository.fetchTrendingNfts();
      emit(TrendingNftLoaded(nfts));
    } catch (e) {
      emit(TrendingNftError("Failed to load NFTs"));
    }
  }
}