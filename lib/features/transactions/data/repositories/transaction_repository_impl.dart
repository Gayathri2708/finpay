import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../datasources/transaction_remote_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;
  final TransactionLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  TransactionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    required int page,
    required int limit,
  }) async {
    final cached = await localDataSource.getTransactions(
      page: page,
      limit: limit,
    );

    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteDataSource.getTransactions(
          page: page,
          limit: limit,
        );
        await localDataSource.cacheTransactions(remote);
        return Right(remote);
      } on ServerException catch (e) {
        if (cached.isNotEmpty) return Right(cached);
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      }
    }

    if (cached.isNotEmpty) return Right(cached);
    if (page == 1) return const Right([]);
    return const Left(NetworkFailure());
  }

  @override
  Future<Either<Failure, void>> syncPendingTransactions() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final pending = await localDataSource.getPendingTransactions();
      for (final transaction in pending) {
        final updated = TransactionModel(
          id: transaction.id,
          fromUserId: transaction.fromUserId,
          toUserId: transaction.toUserId,
          amount: transaction.amount,
          type: transaction.type,
          status: TransactionStatus.completed,
          description: transaction.description,
          createdAt: transaction.createdAt,
        );
        await localDataSource.updateTransaction(updated);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
