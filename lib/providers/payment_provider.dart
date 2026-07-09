import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/payment_model.dart';
import '../services/api_service.dart';

part 'payment_provider.g.dart';

@riverpod
Future<List<PaymentWithCustomer>> paymentList(Ref ref) async {
  final res = await DioClient.instance.dio.get('/Payment/');
  return (res.data as List)
      .map((j) => PaymentWithCustomer.fromJson(j as Map<String, dynamic>))
      .toList();
}

@riverpod
Future<List<PaymentWithCustomer>> customerPayments(
    Ref ref, int custId) async {
  final res =
      await DioClient.instance.dio.get('/Payment/Customer/$custId');
  return (res.data as List)
      .map((j) => PaymentWithCustomer.fromJson(j as Map<String, dynamic>))
      .toList();
}

/// Current user's own payments — GET /User/Me/Payments (Employee / Salesman)
@riverpod
Future<List<PaymentWithCustomer>> myPaymentList(Ref ref) async {
  final res = await DioClient.instance.dio.get('/User/Me/Payments');
  return (res.data as List)
      .map((j) => PaymentWithCustomer.fromJson(j as Map<String, dynamic>))
      .toList();
}
