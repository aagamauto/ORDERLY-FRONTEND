import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';

part 'user_provider.g.dart';

/// Returns all staff users — admin only endpoint.
@riverpod
Future<List<UserModel>> userList(Ref ref) async {
  final res = await DioClient.instance.dio.get('/Admin/Users/');
  return (res.data as List)
      .map((j) => UserModel.fromJson(j as Map<String, dynamic>))
      .toList();
}
