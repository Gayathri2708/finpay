import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<Either<Failure, WalletEntity>> getWallet();
  Future<Either<Failure, WalletEntity>> sendMoney({
    required String toPhone,
    required double amount,
    required String description,
  });
}
