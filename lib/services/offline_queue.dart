import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

/// A create-order request that was captured while offline and is waiting to sync.
class PendingOrder {
  PendingOrder({required this.id, required this.payload});

  final String id;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toJson() => {'id': id, 'payload': payload};

  factory PendingOrder.fromJson(Map<String, dynamic> j) => PendingOrder(
        id: j['id'] as String,
        payload: (j['payload'] as Map).cast<String, dynamic>(),
      );
}

/// Simple offline-first queue for new orders.
///
/// When the salesman is offline, the order payload is stored locally
/// (shared_preferences). Whenever connectivity returns — or the app starts —
/// the queue flushes to `POST /Orders/add/`. Fully on-device, no cost.
class OfflineQueue {
  OfflineQueue._();
  static final OfflineQueue instance = OfflineQueue._();

  static const _key = 'pending_orders_v1';

  /// Number of orders still waiting to sync. UI can listen to show a badge.
  final ValueNotifier<int> pendingCount = ValueNotifier<int>(0);

  bool _flushing = false;

  Future<void> init() async {
    await _refreshCount();
    Connectivity().onConnectivityChanged.listen((results) {
      if (_isOnline(results)) flush();
    });
    // Best-effort flush on startup.
    flush();
  }

  bool _isOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  Future<bool> isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return _isOnline(results);
  }

  Future<List<PendingOrder>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const [];
    return raw
        .map((s) => PendingOrder.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _save(List<PendingOrder> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _key, list.map((p) => jsonEncode(p.toJson())).toList());
    pendingCount.value = list.length;
  }

  Future<void> _refreshCount() async {
    pendingCount.value = (await _load()).length;
  }

  /// Store an order to be sent later.
  Future<void> enqueue(Map<String, dynamic> payload) async {
    final list = await _load();
    list.add(PendingOrder(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      payload: payload,
    ));
    await _save(list);
  }

  /// Try to push every queued order. Safe to call repeatedly.
  Future<void> flush() async {
    if (_flushing) return;
    _flushing = true;
    try {
      final list = await _load();
      if (list.isEmpty) return;
      if (!await isOnline()) return;

      final remaining = <PendingOrder>[];
      for (final p in list) {
        try {
          await DioClient.instance.dio.post('/Orders/add/', data: p.payload);
          // success -> drop it
        } on DioException catch (e) {
          final status = e.response?.statusCode;
          final networky = e.response == null ||
              e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout;
          // Keep it if it's a transient failure (offline / auth expired / server down);
          // drop it on a genuine client rejection (bad data) so we don't loop forever.
          if (networky || status == 401 || (status != null && status >= 500)) {
            remaining.add(p);
          }
        }
      }
      await _save(remaining);
    } finally {
      _flushing = false;
    }
  }
}
