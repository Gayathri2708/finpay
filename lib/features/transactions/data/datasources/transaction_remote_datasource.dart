import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getTransactions({
    required int page,
    required int limit,
  });
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final ApiClient apiClient;

  TransactionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<TransactionModel>> getTransactions({
    required int page,
    required int limit,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.transactions,
        queryParameters: {'page': page, 'limit': limit},
      );
      final list = response.data['transactions'] as List;
      return list.map((e) => TransactionModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ServerException(
        message:
            e.response?.data?['message'] ?? 'Failed to fetch transactions',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
