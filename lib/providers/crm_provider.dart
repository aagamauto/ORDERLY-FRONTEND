import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/crm_model.dart';
import '../services/api_service.dart';

part 'crm_provider.g.dart';

/// CRM analytics for one business — GET /CRM/Analytics/?shop=
@riverpod
Future<List<CrmAnalytics>> crmAnalytics(Ref ref, String shop) async {
  final res = await DioClient.instance.dio
      .get('/CRM/Analytics/', queryParameters: {'shop': shop});
  return (res.data as List)
      .map((j) => CrmAnalytics.fromJson(j as Map<String, dynamic>))
      .toList();
}

/// All per-business config rows — GET /CRM/Config/
@riverpod
Future<List<CrmConfig>> crmConfigList(Ref ref) async {
  final res = await DioClient.instance.dio.get('/CRM/Config/');
  return (res.data as List)
      .map((j) => CrmConfig.fromJson(j as Map<String, dynamic>))
      .toList();
}
