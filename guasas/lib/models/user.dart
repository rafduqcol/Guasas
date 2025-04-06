class User {
  String uid;
  String firstName;
  String lastName;
  String username;
  String email;
  String password;
  String avatarUrl;

  User({
    this.uid = '',
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.password,
    required this.avatarUrl,
  });

  // Método para convertir un Map a un objeto User
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
    );
  }

  // Método para convertir un objeto User a un Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'password': password,
      'avatarUrl': avatarUrl,
    };
  }
}
