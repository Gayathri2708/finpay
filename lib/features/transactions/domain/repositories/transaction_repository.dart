import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    required int page,
    required int limit,
  });
  Future<Either<Failure, void>> syncPendingTransactions();
}
