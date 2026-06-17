class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.finpay.dev/v1';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String profile = '/user/profile';
  static const String wallet = '/wallet';
  static const String walletSend = '/wallet/send';
  static const String transactions = '/transactions';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
