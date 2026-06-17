// Handles FCM push notifications — foreground, background, and terminated state.
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../network/api_client.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FlutterSecureStorage _storage;
  final ApiClient _apiClient;
  GoRouter? _router;

  NotificationService({
    required FlutterSecureStorage storage,
    required ApiClient apiClient,
  })  : _storage = storage,
        _apiClient = apiClient;

  void setRouter(GoRouter router) => _router = router;

  Future<void> initialize() async {
    await _requestPermissions();
    await _initLocalNotifications();
    await _configureFCM();
    await _saveFcmToken();
  }

  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  Future<void> _configureFCM() async {
    // Foreground messages — show as local notification
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    // Background/terminated tap — navigate to correct screen
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationNavigation);

    // Check if app was opened from a terminated-state notification
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _handleNotificationNavigation(initial);
    }

    // Refresh token when it changes
    _messaging.onTokenRefresh.listen((token) async {
      await _storage.write(key: AppConstants.fcmTokenKey, value: token);
      await _sendTokenToBackend(token);
    });
  }

  Future<void> _saveFcmToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _storage.write(key: AppConstants.fcmTokenKey, value: token);
      await _sendTokenToBackend(token);
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      await _apiClient.dio.post(
        ApiConstants.fcmToken,
        data: {'fcm_token': token},
      );
    } catch (_) {
      // Silently fail — token will be retried on next app launch
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    const channel = AndroidNotificationChannel(
      'finpay_channel',
      'FinPay Notifications',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    final data = jsonDecode(response.payload!) as Map<String, dynamic>;
    _navigateByPayload(data);
  }

  void _handleNotificationNavigation(RemoteMessage message) {
    _navigateByPayload(message.data);
  }

  void _navigateByPayload(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    switch (type) {
      case 'transaction':
        final id = data['transaction_id'] as String?;
        if (id != null) _router?.push('/transaction/$id');
      case 'send_money':
        _router?.push('/send-money');
      default:
        _router?.push('/home');
    }
  }
}
