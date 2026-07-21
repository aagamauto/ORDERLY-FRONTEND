import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/call_model.dart';
import '../services/api_service.dart';

part 'call_provider.g.dart';

/// Today's follow-up call list for a business (server caps at the daily target).
@riverpod
Future<List<CallCandidate>> callToday(Ref ref, String shop) async {
  final res = await DioClient.instance.dio.get(
    '/CRM/Calls/Today/',
    queryParameters: {'shop': shop},
  );
  return (res.data as List)
      .map((j) => CallCandidate.fromJson(j as Map<String, dynamic>))
      .toList();
}
