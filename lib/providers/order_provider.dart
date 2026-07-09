import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/order_model.dart';
import '../services/api_service.dart';

part 'order_provider.g.dart';

@riverpod
Future<List<OrderSummary>> orderList(Ref ref) async {
  final res = await DioClient.instance.dio.get('/Orders/');
  return (res.data as List)
      .map((j) => OrderSummary.fromJson(j as Map<String, dynamic>))
      .toList();
}

@riverpod
Future<OrderDetail> orderDetail(Ref ref, int orderId) async {
  final res = await DioClient.instance.dio.get('/Orders/$orderId/');
  return OrderDetail.fromJson(res.data as Map<String, dynamic>);
}

@riverpod
Future<OrderPreload> orderPreload(Ref ref) async {
  final res = await DioClient.instance.dio.get('/Orders/add/');
  return OrderPreload.fromJson(res.data as Map<String, dynamic>);
}

/// Current user's own orders — GET /User/Me/Orders (Employee / Salesman)
@riverpod
Future<List<OrderSummary>> myOrderList(Ref ref) async {
  final res = await DioClient.instance.dio.get('/User/Me/Orders');
  return (res.data as List)
      .map((j) => OrderSummary.fromJson(j as Map<String, dynamic>))
      .toList();
}

/// Dispatch queue — orders still needing action (Ordered + Packed), oldest
/// first. Employee/Admin only — GET /Orders/queue/
@riverpod
Future<List<QueueOrder>> dispatchQueue(Ref ref) async {
  final res = await DioClient.instance.dio.get('/Orders/queue/');
  return (res.data as List)
      .map((j) => QueueOrder.fromJson(j as Map<String, dynamic>))
      .toList();
}
