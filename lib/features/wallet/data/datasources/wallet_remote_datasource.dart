import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> getWallet();
  Future<WalletModel> sendMoney({
    required String toPhone,
    required double amount,
    required String description,
  });
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final ApiClient apiClient;

  WalletRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<WalletModel> getWallet() async {
    try {
      final response = await apiClient.dio.get(ApiConstants.wallet);
      return WalletModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to fetch wallet',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<WalletModel> sendMoney({
    required String toPhone,
    required double amount,
    required String description,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.walletSend,
        data: {
          'to_phone': toPhone,
          'amount': amount,
          'description': description,
        },
      );
      return WalletModel.fromJson(response.data['wallet']);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to send money',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
