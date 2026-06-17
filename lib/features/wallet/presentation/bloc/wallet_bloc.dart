import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/network_info.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/usecases/get_wallet_usecase.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletUseCase getWalletUseCase;
  final NetworkInfo networkInfo;

  WalletBloc({
    required this.getWalletUseCase,
    required this.networkInfo,
  }) : super(WalletInitial()) {
    on<WalletLoadRequested>(_onLoadRequested);
    on<WalletRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    WalletLoadRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    await _fetchWallet(emit);
  }

  Future<void> _onRefreshRequested(
    WalletRefreshRequested event,
    Emitter<WalletState> emit,
  ) async {
    await _fetchWallet(emit);
  }

  Future<void> _fetchWallet(Emitter<WalletState> emit) async {
    final isOnline = await networkInfo.isConnected;
    final result = await getWalletUseCase();
    result.fold(
      (failure) => emit(WalletError(message: failure.message)),
      (wallet) => emit(WalletLoaded(wallet: wallet, isOffline: !isOnline)),
    );
  }
}
