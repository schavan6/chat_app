class User {
  User({
    this.id,
    this.name,
    this.email,
  });

  factory User.fromMap(Map<String, dynamic> data) {
  print(data);
    return User(
        id: data['uid'], name: data['name'], email: data['email']);
  }

  final String id;
  final String name;
  final String email;
}