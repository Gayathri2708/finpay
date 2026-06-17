part of 'transaction_bloc.dart';

sealed class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

final class TransactionsLoadRequested extends TransactionEvent {
  final int page;

  const TransactionsLoadRequested({this.page = 1});

  @override
  List<Object?> get props => [page];
}

final class TransactionsLoadMore extends TransactionEvent {}

final class TransactionsRefreshRequested extends TransactionEvent {}
