import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/check_auth_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthUseCase checkAuthUseCase;
  final FlutterSecureStorage secureStorage;

  UserEntity? _lastUser;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.checkAuthUseCase,
    required this.secureStorage,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthRequested>(_onCheckAuthRequested);
    on<AppPaused>(_onAppPaused);
    on<AppResumed>(_onAppResumed);
    on<SessionUnlocked>(_onSessionUnlocked);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginUseCase(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) {
        _lastUser = user;
        emit(Authenticated(user: user));
      },
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await registerUseCase(
      fullName: event.fullName,
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) {
        _lastUser = user;
        emit(Authenticated(user: user));
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await logoutUseCase();
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) {
        _lastUser = null;
        emit(Unauthenticated());
      },
    );
  }

  Future<void> _onCheckAuthRequested(
    CheckAuthRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await checkAuthUseCase();
    result.fold(
      (_) => emit(Unauthenticated()),
      (user) {
        _lastUser = user;
        emit(Authenticated(user: user));
      },
    );
  }

  Future<void> _onAppPaused(
    AppPaused event,
    Emitter<AuthState> emit,
  ) async {
    await secureStorage.write(
      key: AppConstants.lastActiveKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  Future<void> _onAppResumed(
    AppResumed event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! Authenticated) return;

    final lastActiveStr = await secureStorage.read(
      key: AppConstants.lastActiveKey,
    );
    if (lastActiveStr == null) return;

    final lastActive = DateTime.tryParse(lastActiveStr);
    if (lastActive == null) return;

    final elapsed = DateTime.now().difference(lastActive);
    if (elapsed > AppConstants.sessionTimeout) {
      emit(SessionExpired());
    }
  }

  Future<void> _onSessionUnlocked(
    SessionUnlocked event,
    Emitter<AuthState> emit,
  ) async {
    if (_lastUser != null) {
      emit(Authenticated(user: _lastUser!));
    } else {
      final result = await checkAuthUseCase();
      result.fold(
        (_) => emit(Unauthenticated()),
        (user) {
          _lastUser = user;
          emit(Authenticated(user: user));
        },
      );
    }
  }
}
