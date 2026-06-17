import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<({UserModel user, String accessToken, String refreshToken})> login({
    required String email,
    required String password,
  });

  Future<({UserModel user, String accessToken, String refreshToken})> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<void> logout(String accessToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<({UserModel user, String accessToken, String refreshToken})> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      return (
        user: UserModel.fromJson(response.data['user']),
        accessToken: response.data['access_token'] as String,
        refreshToken: response.data['refresh_token'] as String,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Login failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<({UserModel user, String accessToken, String refreshToken})> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.register,
        data: {
          'full_name': fullName,
          'email': email,
          'password': password,
        },
      );

      return (
        user: UserModel.fromJson(response.data['user']),
        accessToken: response.data['access_token'] as String,
        refreshToken: response.data['refresh_token'] as String,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Registration failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> logout(String accessToken) async {
    try {
      await apiClient.dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Logout failed',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
