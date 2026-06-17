// PIN/Biometric lock screen shown on app resume after inactivity timeout.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/security/app_lock_service.dart';
import '../../../../core/security/biometric_service.dart';
import '../bloc/auth_bloc.dart';

class LockScreenPage extends StatefulWidget {
  const LockScreenPage({super.key});

  @override
  State<LockScreenPage> createState() => _LockScreenPageState();
}

class _LockScreenPageState extends State<LockScreenPage> {
  final _appLockService = sl<AppLockService>();
  final _biometricService = sl<BiometricService>();

  String _enteredPin = '';
  int _failedAttempts = 0;
  bool _isLocked = false;
  int _lockCountdown = 0;
  Timer? _lockTimer;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkBiometric() async {
    final result = await _biometricService.isAvailable();
    result.fold(
      (_) {},
      (available) {
        setState(() => _biometricAvailable = available);
        if (available) _authenticateWithBiometric();
      },
    );
  }

  Future<void> _authenticateWithBiometric() async {
    final result = await _biometricService.authenticate();
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        }
      },
      (success) {
        if (success && mounted) {
          context.read<AuthBloc>().add(SessionUnlocked());
        }
      },
    );
  }

  void _onDigitPressed(String digit) {
    if (_isLocked || _enteredPin.length >= 6) return;

    setState(() => _enteredPin += digit);

    if (_enteredPin.length == 6) {
      _verifyPin();
    }
  }

  void _onBackspacePressed() {
    if (_enteredPin.isEmpty || _isLocked) return;
    setState(() => _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1));
  }

  Future<void> _verifyPin() async {
    final result = await _appLockService.verifyPin(_enteredPin);
    result.fold(
      (failure) {
        _handleFailedAttempt();
      },
      (isCorrect) {
        if (isCorrect) {
          if (mounted) context.read<AuthBloc>().add(SessionUnlocked());
        } else {
          _handleFailedAttempt();
        }
      },
    );
  }

  void _handleFailedAttempt() {
    _failedAttempts++;
    setState(() => _enteredPin = '');

    if (_failedAttempts >= 3) {
      _startLockout();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incorrect PIN. ${3 - _failedAttempts} attempts remaining'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _startLockout() {
    setState(() {
      _isLocked = true;
      _lockCountdown = 30;
    });

    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _lockCountdown--);
      if (_lockCountdown <= 0) {
        timer.cancel();
        setState(() {
          _isLocked = false;
          _failedAttempts = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: AppColors.primary),
              const SizedBox(height: 24),
              Text(
                _isLocked
                    ? 'Too many attempts'
                    : 'Enter your PIN',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_isLocked)
                Text(
                  'Try again in $_lockCountdown seconds',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
                )
              else
                Text(
                  'Enter your 6-digit PIN to unlock',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(height: 32),
              _buildPinDots(),
              const SizedBox(height: 40),
              _buildKeypad(),
              const SizedBox(height: 24),
              if (_biometricAvailable)
                TextButton.icon(
                  onPressed: _isLocked ? null : _authenticateWithBiometric,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Use Biometrics'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final isFilled = index < _enteredPin.length;
        return Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? AppColors.primary : Colors.transparent,
            border: Border.all(
              color: _isLocked ? AppColors.error : AppColors.primary,
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildKeypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'backspace'],
    ];

    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            if (key.isEmpty) return const SizedBox(width: 80, height: 64);

            if (key == 'backspace') {
              return SizedBox(
                width: 80,
                height: 64,
                child: IconButton(
                  onPressed: _onBackspacePressed,
                  icon: const Icon(Icons.backspace_outlined),
                ),
              );
            }

            return SizedBox(
              width: 80,
              height: 64,
              child: TextButton(
                onPressed: _isLocked ? null : () => _onDigitPressed(key),
                child: Text(
                  key,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
