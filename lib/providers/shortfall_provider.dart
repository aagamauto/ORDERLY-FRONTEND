import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/pending_model.dart';
import '../services/api_service.dart';

part 'shortfall_provider.g.dart';

/// A customer's pending short items — order-taking + customer detail.
@riverpod
Future<List<PendingShort>> pendingShorts(Ref ref, int custId) async {
  final res = await DioClient.instance.dio.get('/Shortfalls/Customer/$custId/');
  return (res.data as List)
      .map((j) => PendingShort.fromJson(j as Map<String, dynamic>))
      .toList();
}

/// All pending shorts across customers — the global short-orders list.
@riverpod
Future<List<PendingShort>> allPendingShorts(Ref ref) async {
  final res = await DioClient.instance.dio.get('/Shortfalls/Pending/');
  return (res.data as List)
      .map((j) => PendingShort.fromJson(j as Map<String, dynamic>))
      .toList();
}

/// Per-product short analytics — which products keep going short.
@riverpod
Future<List<ShortProduct>> shortfallAnalytics(Ref ref) async {
  final res = await DioClient.instance.dio.get('/Shortfalls/Analytics/');
  return (res.data as List)
      .map((j) => ShortProduct.fromJson(j as Map<String, dynamic>))
      .toList();
}
