import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_local_datasource.dart';
import '../datasources/wallet_remote_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;
  final WalletLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  WalletRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, WalletEntity>> getWallet() async {
    final cachedWallet = await localDataSource.getWallet();

    if (await networkInfo.isConnected) {
      try {
        final remoteWallet = await remoteDataSource.getWallet();
        await localDataSource.cacheWallet(remoteWallet);
        return Right(remoteWallet);
      } on ServerException catch (e) {
        if (cachedWallet != null) return Right(cachedWallet);
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      }
    }

    if (cachedWallet != null) return Right(cachedWallet);
    return const Left(NetworkFailure());
  }

  @override
  Future<Either<Failure, WalletEntity>> sendMoney({
    required String toPhone,
    required double amount,
    required String description,
  }) async {
    final cachedWallet = await localDataSource.getWallet();
    if (cachedWallet != null) {
      await localDataSource.updateBalance(cachedWallet.balance - amount);
    }

    if (!await networkInfo.isConnected) {
      if (cachedWallet != null) {
        await localDataSource.updateBalance(cachedWallet.balance);
      }
      return const Left(NetworkFailure());
    }

    try {
      final updatedWallet = await remoteDataSource.sendMoney(
        toPhone: toPhone,
        amount: amount,
        description: description,
      );
      await localDataSource.cacheWallet(updatedWallet);
      return Right(updatedWallet);
    } on ServerException catch (e) {
      if (cachedWallet != null) {
        await localDataSource.updateBalance(cachedWallet.balance);
      }
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
