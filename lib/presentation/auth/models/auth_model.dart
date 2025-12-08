class AuthModel {
  final String? username;
  final String? password;
  final String? email;
  final String? token;
  final String? userId;

  AuthModel({
    this.username,
    this.password,
    this.email,
    this.token,
    this.userId,
  });

  AuthModel copyWith({
    String? username,
    String? password,
    String? email,
    String? token,
    String? userId,
  }) {
    return AuthModel(
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      token: token ?? this.token,
      userId: userId ?? this.userId,
    );
  }
}
