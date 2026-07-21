import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/visit_model.dart';
import '../services/api_service.dart';
import 'customer_provider.dart';

part 'visit_provider.g.dart';

/// Ranked customers to visit for a business + set of cities.
/// [citiesCsv] is a comma-joined, sorted list so the family key stays stable.
@riverpod
Future<List<VisitCandidate>> visitPlan(
    Ref ref, String shop, String citiesCsv) async {
  final res = await DioClient.instance.dio.get(
    '/CRM/Visits/Recommendations/',
    queryParameters: {'shop': shop, 'cities': citiesCsv},
  );
  return (res.data as List)
      .map((j) => VisitCandidate.fromJson(j as Map<String, dynamic>))
      .toList();
}

/// Distinct cities that have customers for the given business — derived from the
/// already-loaded customer list (no extra endpoint needed).
@riverpod
Future<List<String>> visitCities(Ref ref, String shop) async {
  final customers = await ref.watch(customerListProvider.future);
  final cities = customers
      .where((c) => c.shop == shop && c.city.isNotEmpty)
      .map((c) => c.city)
      .toSet()
      .toList();
  cities.sort();
  return cities;
}
