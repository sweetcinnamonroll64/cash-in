class UserModel {
  final String? id;
  final String userId;
  final String password;
  final String? email;
  final DateTime? createdAt;

  const UserModel({
    this.id,
    required this.userId,
    required this.password,
    this.email,
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String?,
      userId: map['user_id'] as String,
      password: map['password'] as String,
      email: map['email'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id':  userId,
      'password': password,
      if (email != null) 'email': email,
    };
  }
}
