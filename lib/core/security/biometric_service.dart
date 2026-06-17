// Wraps the local_auth package to provide biometric authentication with typed error handling.
import 'package:dartz/dartz.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

import '../errors/failures.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<Either<Failure, bool>> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return Right(canCheck && isSupported);
    } catch (e) {
      return Left(BiometricFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<BiometricType>>> getBiometricTypes() async {
    try {
      final types = await _auth.getAvailableBiometrics();
      return Right(types);
    } catch (e) {
      return Left(BiometricFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, bool>> authenticate({
    String reason = 'Please authenticate to access FinPay',
  }) async {
    try {
      final result = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return Right(result);
    } on Exception catch (e) {
      final message = e.toString();

      // Device has no biometric hardware
      if (message.contains(auth_error.notAvailable)) {
        return const Left(
          BiometricFailure(message: 'Biometric hardware not available'),
        );
      }

      // User has not enrolled any biometrics (no fingerprint/face registered)
      if (message.contains(auth_error.notEnrolled)) {
        return const Left(
          BiometricFailure(message: 'No biometrics enrolled on this device'),
        );
      }

      // Too many failed attempts — temporarily locked
      if (message.contains(auth_error.lockedOut)) {
        return const Left(
          BiometricFailure(
            message: 'Too many attempts. Biometric temporarily locked',
          ),
        );
      }

      // Permanently locked — requires device passcode to re-enable
      if (message.contains(auth_error.permanentlyLockedOut)) {
        return const Left(
          BiometricFailure(
            message: 'Biometric permanently locked. Use device passcode',
          ),
        );
      }

      return Left(BiometricFailure(message: message));
    }
  }
}
