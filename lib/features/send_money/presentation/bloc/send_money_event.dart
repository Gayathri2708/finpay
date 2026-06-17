part of 'send_money_bloc.dart';

sealed class SendMoneyEvent extends Equatable {
  const SendMoneyEvent();

  @override
  List<Object?> get props => [];
}

final class SendMoneySubmitted extends SendMoneyEvent {
  final String toPhone;
  final double amount;
  final String description;

  const SendMoneySubmitted({
    required this.toPhone,
    required this.amount,
    this.description = '',
  });

  @override
  List<Object?> get props => [toPhone, amount, description];
}
