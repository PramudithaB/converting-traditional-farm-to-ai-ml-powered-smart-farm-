class User {
  final int id;
  final String name;
  final String username;
  final String email;
  final String mobile;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.mobile,
  });

  factory User.fromMap(Map<String, Object?> map) {
    return User(
      id: map['id'] as int,
      name: map['name'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      mobile: map['mobile'] as String,
    );
  }
}