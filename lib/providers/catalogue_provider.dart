import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/catalogue_model.dart';
import '../services/api_service.dart';

part 'catalogue_provider.g.dart';

@riverpod
Future<List<CatalogueModel>> catalogueList(Ref ref) async {
  final res = await DioClient.instance.dio.get('/Catalogue/');
  return (res.data as List)
      .map((j) => CatalogueModel.fromJson(j as Map<String, dynamic>))
      .toList();
}

@riverpod
Future<List<String>> catalogueCategories(Ref ref) async {
  final res = await DioClient.instance.dio.get('/Catalogue/Categories');
  return List<String>.from(res.data as List);
}

@riverpod
class SelectedCatalogueCategory extends _$SelectedCatalogueCategory {
  @override
  String? build() => null;

  void set(String? category) => state = category;
}
