import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/product_model.dart';
import '../services/api_service.dart';

part 'product_provider.g.dart';

@riverpod
Future<List<ProductModel>> productList(Ref ref) async {
  final res = await DioClient.instance.dio.get('/Product/');
  return (res.data as List)
      .map((j) => ProductModel.fromJson(j as Map<String, dynamic>))
      .toList();
}

@riverpod
Future<List<String>> productCategories(Ref ref) async {
  final res = await DioClient.instance.dio.get('/Product/Categories');
  return List<String>.from(res.data as List);
}
