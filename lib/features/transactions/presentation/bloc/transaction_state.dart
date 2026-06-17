part of 'transaction_bloc.dart';

sealed class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

final class TransactionInitial extends TransactionState {}

final class TransactionLoading extends TransactionState {}

final class TransactionLoaded extends TransactionState {
  final List<TransactionEntity> transactions;
  final bool hasMore;
  final bool isOffline;

  const TransactionLoaded({
    required this.transactions,
    this.hasMore = true,
    this.isOffline = false,
  });

  @override
  List<Object?> get props => [transactions, hasMore, isOffline];
}

final class TransactionError extends TransactionState {
  final String message;

  const TransactionError({required this.message});

  @override
  List<Object?> get props => [message];
}
