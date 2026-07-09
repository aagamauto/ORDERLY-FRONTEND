import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'api_service.dart';

@pragma('vm:entry-point')
Future<void> _bgHandler(RemoteMessage message) async {
  // The system displays background notifications automatically.
}

/// Firebase Cloud Messaging client. Registers this device with the backend so
/// the server can push notifications (new order / order edited / dispatched).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  Future<void> init() async {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_bgHandler);
    await FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.instance.onTokenRefresh.listen(_register);
  }

  /// Call AFTER a successful login (token already in secure storage).
  Future<void> registerToken() async =>
      _register(await FirebaseMessaging.instance.getToken());

  Future<void> _register(String? token) async {
    if (token == null) return;
    try {
      await DioClient.instance.dio
          .post('/User/Me/DeviceToken', data: {'token': token});
    } on DioException catch (e) {
      debugPrint('FCM register failed: $e');
    }
  }

  /// Call on logout, BEFORE clearing secure storage (the call needs the token).
  Future<void> unregisterToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await DioClient.instance.dio
            .delete('/User/Me/DeviceToken', data: {'token': token});
      }
    } catch (_) {}
  }
}
