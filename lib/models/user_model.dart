class UserModel {
  const UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
  });

  final int userId;
  final String name;
  final String email;
  final String role;

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        userId: j['user_id'] as int,
        name: j['name'] as String,
        email: j['email'] as String,
        role: j['role'] as String,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'name': name,
        'email': email,
        'role': role,
      };
}
