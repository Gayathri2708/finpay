part of 'wallet_bloc.dart';

sealed class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

final class WalletLoadRequested extends WalletEvent {}

final class WalletRefreshRequested extends WalletEvent {}
