import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/transaction_repository.dart';

class SyncPendingTransactionsUseCase {
  final TransactionRepository repository;

  SyncPendingTransactionsUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.syncPendingTransactions();
  }
}
