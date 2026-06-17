import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final result = await remoteDataSource.login(
        email: email,
        password: password,
      );
      await localDataSource.cacheTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await localDataSource.cacheUser(result.user);
      return Right(result.user);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final result = await remoteDataSource.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      await localDataSource.cacheTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await localDataSource.cacheUser(result.user);
      return Right(result.user);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final token = await localDataSource.getAccessToken();
      if (token != null) {
        await remoteDataSource.logout(token);
      }
      await localDataSource.clearCache();
      return const Right(null);
    } on ServerException catch (e) {
      await localDataSource.clearCache();
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> checkAuth() async {
    try {
      final token = await localDataSource.getAccessToken();
      if (token == null) {
        return const Left(AuthFailure(message: 'Not authenticated'));
      }
      final user = await localDataSource.getCachedUser();
      if (user == null) {
        return const Left(AuthFailure(message: 'No cached user'));
      }
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
