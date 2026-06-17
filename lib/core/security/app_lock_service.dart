// Manages a 6-digit PIN stored in flutter_secure_storage for app-level locking.
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';
import '../errors/failures.dart';

class AppLockService {
  final FlutterSecureStorage _storage;

  AppLockService({required FlutterSecureStorage storage}) : _storage = storage;

  Future<Either<Failure, bool>> hasPin() async {
    try {
      final pin = await _storage.read(key: AppConstants.pinKey);
      return Right(pin != null);
    } catch (e) {
      return Left(PinFailure(message: 'Failed to check PIN: $e'));
    }
  }

  Future<Either<Failure, void>> setPin(String pin) async {
    if (pin.length != 6 || int.tryParse(pin) == null) {
      return const Left(PinFailure(message: 'PIN must be exactly 6 digits'));
    }
    try {
      await _storage.write(key: AppConstants.pinKey, value: pin);
      return const Right(null);
    } catch (e) {
      return Left(PinFailure(message: 'Failed to save PIN: $e'));
    }
  }

  Future<Either<Failure, bool>> verifyPin(String pin) async {
    try {
      final stored = await _storage.read(key: AppConstants.pinKey);
      if (stored == null) {
        return const Left(PinFailure(message: 'No PIN set'));
      }
      return Right(stored == pin);
    } catch (e) {
      return Left(PinFailure(message: 'Failed to verify PIN: $e'));
    }
  }

  Future<Either<Failure, void>> clearPin() async {
    try {
      await _storage.delete(key: AppConstants.pinKey);
      return const Right(null);
    } catch (e) {
      return Left(PinFailure(message: 'Failed to clear PIN: $e'));
    }
  }
}
