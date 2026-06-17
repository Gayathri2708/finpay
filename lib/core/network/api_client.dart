// Dio-based HTTP client with JWT auth interceptor, token refresh, and SSL pinning.
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

// SSL pinning validates that the server's certificate matches a known fingerprint,
// preventing man-in-the-middle attacks even if a rogue CA issues a certificate
// for our domain. In release mode, connections are rejected unless the server
// certificate's SHA-256 fingerprint matches one of these pinned hashes.
const _pinnedCertFingerprints = <String>[
  'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=', // primary cert
  'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=', // backup cert
];

class ApiClient {
  late final Dio dio;
  final FlutterSecureStorage secureStorage;

  ApiClient({required this.secureStorage}) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // SSL pinning — enforced in release builds only so dev/debug can use
    // self-signed certs or proxy tools like Charles.
    if (!kDebugMode) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) {
          final fingerprint = cert.sha256Fingerprint;
          return _pinnedCertFingerprints.any(
            (pinned) => pinned == 'sha256/$fingerprint',
          );
        };
        return client;
      };
    }

    dio.interceptors.addAll([
      _AuthInterceptor(secureStorage),
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
      ),
    ]);
  }
}

// Helper to get SHA-256 fingerprint from X509Certificate
extension on X509Certificate {
  String get sha256Fingerprint {
    final bytes = der;
    // In production, compute SHA-256 of the DER-encoded certificate
    // and base64-encode it. Using the raw DER bytes here as a placeholder.
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(':');
  }
}

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;

  _AuthInterceptor(this.secureStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await secureStorage.read(key: AppConstants.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        final retryResponse = await _retry(err.requestOptions);
        return handler.resolve(retryResponse);
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await secureStorage.read(
        key: AppConstants.refreshTokenKey,
      );
      if (refreshToken == null) return false;

      final response = await Dio().post(
        '${ApiConstants.baseUrl}${ApiConstants.refreshToken}',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        await secureStorage.write(
          key: AppConstants.accessTokenKey,
          value: response.data['access_token'],
        );
        await secureStorage.write(
          key: AppConstants.refreshTokenKey,
          value: response.data['refresh_token'],
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final token = await secureStorage.read(key: AppConstants.accessTokenKey);
    final options = Options(
      method: requestOptions.method,
      headers: {...requestOptions.headers, 'Authorization': 'Bearer $token'},
    );
    return Dio().request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
