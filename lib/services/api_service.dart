import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/constants.dart';

/// A global notifier that fires when the server returns 401 Unauthorized.
/// GoRouter listens to this stream to redirect the user to /login.
final authFailureNotifier = ValueNotifier<bool>(false);

class DioClient {
  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: kBaseUrl,
        // Render free tier spins the server down after idle; the first request
        // of the morning triggers a ~30-60s cold boot. Allow for it so that
        // first call resolves instead of failing at 10s.
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 45),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(_AuthInterceptor(_storage));

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (o) => debugPrint(o.toString()),
        ),
      );
    }
  }

  static final DioClient instance = DioClient._internal();

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  const _AuthInterceptor(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: kTokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Clear all stored credentials and signal app to redirect to login.
      _storage.deleteAll().then((_) {
        authFailureNotifier.value = !authFailureNotifier.value;
      });
    }
    handler.next(err);
  }
}
