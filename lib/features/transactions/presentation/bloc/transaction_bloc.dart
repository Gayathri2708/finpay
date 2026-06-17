import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/network_info.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/get_transactions_usecase.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactionsUseCase getTransactionsUseCase;
  final NetworkInfo networkInfo;

  static const _pageSize = 20;
  int _currentPage = 1;

  TransactionBloc({
    required this.getTransactionsUseCase,
    required this.networkInfo,
  }) : super(TransactionInitial()) {
    on<TransactionsLoadRequested>(_onLoadRequested);
    on<TransactionsLoadMore>(_onLoadMore);
    on<TransactionsRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    TransactionsLoadRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    _currentPage = event.page;
    final isOnline = await networkInfo.isConnected;
    final result = await getTransactionsUseCase(
      page: _currentPage,
      limit: _pageSize,
    );
    result.fold(
      (failure) => emit(TransactionError(message: failure.message)),
      (transactions) => emit(TransactionLoaded(
        transactions: transactions,
        hasMore: transactions.length >= _pageSize,
        isOffline: !isOnline,
      )),
    );
  }

  Future<void> _onLoadMore(
    TransactionsLoadMore event,
    Emitter<TransactionState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TransactionLoaded || !currentState.hasMore) return;

    _currentPage++;
    final isOnline = await networkInfo.isConnected;
    final result = await getTransactionsUseCase(
      page: _currentPage,
      limit: _pageSize,
    );
    result.fold(
      (failure) {
        _currentPage--;
        emit(TransactionLoaded(
          transactions: currentState.transactions,
          hasMore: currentState.hasMore,
          isOffline: !isOnline,
        ));
      },
      (newTransactions) => emit(TransactionLoaded(
        transactions: [...currentState.transactions, ...newTransactions],
        hasMore: newTransactions.length >= _pageSize,
        isOffline: !isOnline,
      )),
    );
  }

  Future<void> _onRefreshRequested(
    TransactionsRefreshRequested event,
    Emitter<TransactionState> emit,
  ) async {
    _currentPage = 1;
    final isOnline = await networkInfo.isConnected;
    final result = await getTransactionsUseCase(
      page: _currentPage,
      limit: _pageSize,
    );
    result.fold(
      (failure) => emit(TransactionError(message: failure.message)),
      (transactions) => emit(TransactionLoaded(
        transactions: transactions,
        hasMore: transactions.length >= _pageSize,
        isOffline: !isOnline,
      )),
    );
  }
}
