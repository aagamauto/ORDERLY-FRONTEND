import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

part 'auth_provider.g.dart';

// ── AuthState ─────────────────────────────────────────────────────────────────

class AuthState {
  const AuthState({
    this.isAuthenticated = false,
    this.token,
    this.userRole,
    this.userName,
    this.userId,
  });

  final bool isAuthenticated;
  final String? token;

  /// One of: "Admin" | "Salesman" | "Employee"
  final String? userRole;
  final String? userName;
  final int? userId;

  AuthState copyWith({
    bool? isAuthenticated,
    String? token,
    String? userRole,
    String? userName,
    int? userId,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      userRole: userRole ?? this.userRole,
      userName: userName ?? this.userName,
      userId: userId ?? this.userId,
    );
  }

  static const unauthenticated = AuthState();
}

// ── AuthNotifier ──────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  static const _storage = FlutterSecureStorage();

  /// Called once on app start. Restores session from secure storage if available.
  @override
  Future<AuthState> build() async {
    final token = await _storage.read(key: kTokenKey);
    if (token == null || token.isEmpty) return AuthState.unauthenticated;

    final role   = await _storage.read(key: kRoleKey);
    final name   = await _storage.read(key: kUserNameKey);
    final idStr  = await _storage.read(key: kUserIdKey);

    return AuthState(
      isAuthenticated: true,
      token: token,
      userRole: role,
      userName: name,
      userId: idStr != null ? int.tryParse(idStr) : null,
    );
  }

  // ── Public Actions ──────────────────────────────────────────────────────────

  /// Logs in with [email] / [password].
  /// On success: stores credentials, fetches profile, updates state.
  /// Throws [DioException] on network error or wrong credentials (401).
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    try {
      final dio = DioClient.instance.dio;

      // 1. Get JWT token via form-data login
      final loginRes = await dio.post(
        '/Login',
        data: FormData.fromMap({
          'username': email,
          'password': password,
        }),
        options: Options(contentType: 'application/x-www-form-urlencoded'),
      );

      final token = loginRes.data['access_token'] as String;

      // Temporarily store token so the interceptor can attach it for the next call
      await _storage.write(key: kTokenKey, value: token);

      // 2. Fetch the logged-in user's profile
      final profileRes = await dio.get('/User/Me/Profile');
      final profile = profileRes.data as Map<String, dynamic>;

      final role   = profile['role']    as String;
      final name   = profile['name']    as String;
      final userId = profile['user_id'] as int;

      // 3. Persist all identity data
      await Future.wait([
        _storage.write(key: kRoleKey,     value: role),
        _storage.write(key: kUserNameKey, value: name),
        _storage.write(key: kUserIdKey,   value: userId.toString()),
      ]);

      state = AsyncData(
        AuthState(
          isAuthenticated: true,
          token: token,
          userRole: role,
          userName: name,
          userId: userId,
        ),
      );

      // Register this device for push notifications (best-effort).
      try {
        await NotificationService.instance.registerToken();
      } catch (_) {}
    } on DioException {
      await _clearStorage();
      state = const AsyncData(AuthState.unauthenticated);
      rethrow; // Let the UI layer handle displaying the error message
    } catch (e, st) {
      await _clearStorage();
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Logs out: wipes secure storage and resets state.
  Future<void> logout() async {
    // Unregister this device BEFORE clearing the token (the call needs auth).
    try {
      await NotificationService.instance.unregisterToken();
    } catch (_) {}
    await _clearStorage();
    state = const AsyncData(AuthState.unauthenticated);
  }

  Future<void> _clearStorage() async {
    await _storage.deleteAll();
  }
}

// ── Convenience Providers ─────────────────────────────────────────────────────

/// `true` when a valid session exists. Used by GoRouter redirect.
@riverpod
bool isAuthenticated(Ref ref) {
  return ref.watch(authProvider).asData?.value.isAuthenticated ?? false;
}

/// The current user's role string ("Admin", "Salesman", "Employee", or null).
/// Used by screens to show/hide role-specific UI elements.
@riverpod
String? userRole(Ref ref) {
  return ref.watch(authProvider).asData?.value.userRole;
}

/// The current user's display name.
@riverpod
String? userName(Ref ref) {
  return ref.watch(authProvider).asData?.value.userName;
}

/// The current user's numeric ID. Used when creating orders.
@riverpod
int? userId(Ref ref) {
  return ref.watch(authProvider).asData?.value.userId;
}
