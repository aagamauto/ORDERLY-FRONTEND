import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/customer_model.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';

part 'customer_provider.g.dart';

@riverpod
Future<List<CustomerModel>> customerList(Ref ref) async {
  final res = await DioClient.instance.dio.get('/Customer/');
  return (res.data as List)
      .map((j) => CustomerModel.fromJson(j as Map<String, dynamic>))
      .toList();
}

/// Only customers flagged as defaulters.
@riverpod
Future<List<CustomerModel>> defaulterList(Ref ref) async {
  final res = await DioClient.instance.dio
      .get('/Customer/', queryParameters: {'defaulters_only': true});
  return (res.data as List)
      .map((j) => CustomerModel.fromJson(j as Map<String, dynamic>))
      .toList();
}

@riverpod
Future<CustomerModel> customerById(Ref ref, int custId) async {
  final res = await DioClient.instance.dio.get('/Customer/$custId/');
  return CustomerModel.fromJson(res.data as Map<String, dynamic>);
}

@riverpod
Future<List<CustomerOrderSummary>> customerOrders(Ref ref, int custId) async {
  final res = await DioClient.instance.dio.get('/Customer/$custId/Orders/');
  return (res.data as List)
      .map((j) => CustomerOrderSummary.fromJson(j as Map<String, dynamic>))
      .toList();
}

@riverpod
Future<OrderDetail> customerOrderDetail(
    Ref ref, int custId, int orderId) async {
  final res =
      await DioClient.instance.dio.get('/Customer/$custId/Orders/$orderId/');
  return OrderDetail.fromJson(res.data as Map<String, dynamic>);
}
