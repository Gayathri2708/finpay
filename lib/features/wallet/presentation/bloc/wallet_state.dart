part of 'wallet_bloc.dart';

sealed class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

final class WalletInitial extends WalletState {}

final class WalletLoading extends WalletState {}

final class WalletLoaded extends WalletState {
  final WalletEntity wallet;
  final bool isOffline;

  const WalletLoaded({required this.wallet, this.isOffline = false});

  @override
  List<Object?> get props => [wallet, isOffline];
}

final class WalletError extends WalletState {
  final String message;

  const WalletError({required this.message});

  @override
  List<Object?> get props => [message];
}
