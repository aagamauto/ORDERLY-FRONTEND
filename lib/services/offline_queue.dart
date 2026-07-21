import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

/// A mutating API request captured while offline and waiting to sync.
class PendingAction {
  PendingAction({
    required this.id,
    required this.type,
    required this.method,
    required this.endpoint,
    required this.payload,
  });

  final String id; // also carried inside payload as client_uuid for dedup
  final String type; // 'order' | 'visit' | 'call'
  final String method; // 'POST' | 'PUT'
  final String endpoint; // e.g. '/Orders/add/'
  final Map<String, dynamic> payload;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'method': method,
        'endpoint': endpoint,
        'payload': payload,
      };

  factory PendingAction.fromJson(Map<String, dynamic> j) => PendingAction(
        id: j['id'] as String,
        type: (j['type'] as String?) ?? 'order',
        method: (j['method'] as String?) ?? 'POST',
        endpoint: (j['endpoint'] as String?) ?? '/Orders/add/',
        payload: (j['payload'] as Map).cast<String, dynamic>(),
      );
}

/// Offline-first queue for order / visit / call writes.
///
/// When the device is offline the request is stored locally
/// (shared_preferences). Whenever connectivity returns — or the app starts —
/// the queue flushes. Fully on-device, no cost. Each action carries a
/// `client_uuid` so a re-flush after a lost response can't create a duplicate.
class OfflineQueue {
  OfflineQueue._();
  static final OfflineQueue instance = OfflineQueue._();

  static const _key = 'pending_actions_v1';
  static const _legacyKey = 'pending_orders_v1';

  /// Number of items still waiting to sync. UI can listen to show a badge.
  final ValueNotifier<int> pendingCount = ValueNotifier<int>(0);

  bool _flushing = false;

  Future<void> init() async {
    await _migrateLegacy();
    await _refreshCount();
    Connectivity().onConnectivityChanged.listen((results) {
      if (_isOnline(results)) flush();
    });
    // Best-effort flush on startup.
    flush();
  }

  /// Move any orders queued by an older (order-only) build into this queue.
  Future<void> _migrateLegacy() async {
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getStringList(_legacyKey);
    if (legacy == null || legacy.isEmpty) return;
    final list = await _load();
    for (final s in legacy) {
      final j = jsonDecode(s) as Map<String, dynamic>;
      list.add(PendingAction(
        id: (j['id'] as String?) ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        type: 'order',
        method: 'POST',
        endpoint: '/Orders/add/',
        payload: (j['payload'] as Map).cast<String, dynamic>(),
      ));
    }
    await _save(list);
    await prefs.remove(_legacyKey);
  }

  bool _isOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  Future<bool> isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return _isOnline(results);
  }

  Future<List<PendingAction>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const [];
    return raw
        .map((s) =>
            PendingAction.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _save(List<PendingAction> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _key, list.map((p) => jsonEncode(p.toJson())).toList());
    pendingCount.value = list.length;
  }

  Future<void> _refreshCount() async {
    pendingCount.value = (await _load()).length;
  }

  /// Generic enqueue. Injects the queue id into the payload as `client_uuid`
  /// so the server can dedup a re-synced write.
  Future<void> enqueueAction({
    required String type,
    required String method,
    required String endpoint,
    required Map<String, dynamic> payload,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final body = Map<String, dynamic>.from(payload)
      ..putIfAbsent('client_uuid', () => id);
    final list = await _load();
    list.add(PendingAction(
      id: id,
      type: type,
      method: method,
      endpoint: endpoint,
      payload: body,
    ));
    await _save(list);
  }

  /// Backwards-compatible: queue a new order (unchanged call site).
  Future<void> enqueue(Map<String, dynamic> payload) => enqueueAction(
      type: 'order', method: 'POST', endpoint: '/Orders/add/', payload: payload);

  /// Queue a "mark visit" while offline on a tour.
  Future<void> enqueueVisit(Map<String, dynamic> payload) => enqueueAction(
      type: 'visit', method: 'POST', endpoint: '/CRM/Visits/', payload: payload);

  /// Queue a "log call" while offline.
  Future<void> enqueueCall(Map<String, dynamic> payload) => enqueueAction(
      type: 'call', method: 'POST', endpoint: '/CRM/Calls/', payload: payload);

  /// Try to push every queued action. Safe to call repeatedly.
  Future<void> flush() async {
    if (_flushing) return;
    _flushing = true;
    try {
      final list = await _load();
      if (list.isEmpty) return;
      if (!await isOnline()) return;

      final remaining = <PendingAction>[];
      for (final a in list) {
        try {
          if (a.method == 'PUT') {
            await DioClient.instance.dio.put(a.endpoint, data: a.payload);
          } else {
            await DioClient.instance.dio.post(a.endpoint, data: a.payload);
          }
          // success -> drop it
        } on DioException catch (e) {
          final status = e.response?.statusCode;
          final networky = e.response == null ||
              e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout;
          // Keep it if transient (offline / auth expired / server down); drop it
          // on a genuine client rejection (bad data) so we don't loop forever.
          if (networky || status == 401 || (status != null && status >= 500)) {
            remaining.add(a);
          }
        }
      }
      await _save(remaining);
    } finally {
      _flushing = false;
    }
  }
}
