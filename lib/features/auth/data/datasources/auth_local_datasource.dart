import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<String?> getAccessToken();
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cacheTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: accessToken,
      );
      await secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: refreshToken,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to cache tokens: $e');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await secureStorage.write(
        key: AppConstants.userKey,
        value: jsonEncode(user.toJson()),
      );
    } catch (e) {
      throw CacheException(message: 'Failed to cache user: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonStr = await secureStorage.read(key: AppConstants.userKey);
      if (jsonStr == null) return null;
      return UserModel.fromJson(jsonDecode(jsonStr));
    } catch (e) {
      throw CacheException(message: 'Failed to get cached user: $e');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    return secureStorage.read(key: AppConstants.accessTokenKey);
  }

  @override
  Future<void> clearCache() async {
    await secureStorage.delete(key: AppConstants.accessTokenKey);
    await secureStorage.delete(key: AppConstants.refreshTokenKey);
    await secureStorage.delete(key: AppConstants.userKey);
  }
}
