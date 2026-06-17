part of 'send_money_bloc.dart';

sealed class SendMoneyState extends Equatable {
  const SendMoneyState();

  @override
  List<Object?> get props => [];
}

final class SendMoneyInitial extends SendMoneyState {}

final class SendMoneyLoading extends SendMoneyState {}

final class SendMoneySuccess extends SendMoneyState {
  final WalletEntity updatedWallet;

  const SendMoneySuccess({required this.updatedWallet});

  @override
  List<Object?> get props => [updatedWallet];
}

final class SendMoneyFailure extends SendMoneyState {
  final String message;

  const SendMoneyFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
