import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/dashboard_model.dart';
import '../services/api_service.dart';

part 'dashboard_provider.g.dart';

@riverpod
Future<AdminDashboard> adminDashboard(Ref ref) async {
  final res = await DioClient.instance.dio.get('/Admin/Dashboard/');
  return AdminDashboard.fromJson(res.data as Map<String, dynamic>);
}

@riverpod
Future<UserDashboard> myDashboard(Ref ref) async {
  final res = await DioClient.instance.dio.get('/User/Me/Dashboard');
  return UserDashboard.fromJson(res.data as Map<String, dynamic>);
}
