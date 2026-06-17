import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

class SendMoneyUseCase {
  final WalletRepository repository;

  SendMoneyUseCase(this.repository);

  Future<Either<Failure, WalletEntity>> call({
    required String toPhone,
    required double amount,
    required String description,
  }) {
    return repository.sendMoney(
      toPhone: toPhone,
      amount: amount,
      description: description,
    );
  }
}
