class User {
  String uid;
  String firstName;
  String lastName;
  String username;
  String email;
  String password;
  bool onlineStatus;
  DateTime? lastConnection;
  String avatarUrl;

  User({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.password,
    required this.onlineStatus,
    this.lastConnection,
    required this.avatarUrl,
  });

  // Convierte el objeto User a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'password': password,
      'onlineStatus': onlineStatus,
      'lastConnection': lastConnection?.toIso8601String(),
      'avatarUrl': avatarUrl,
    };
  }

  // Convierte un mapa de Firestore a un objeto User
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      onlineStatus: map['onlineStatus'],
      lastConnection: map['lastConnection'] != null ? DateTime.parse(map['lastConnection']) : null,
      avatarUrl: map['avatarUrl'],
    );
  }

  // Método copyWith para crear una nueva instancia de User modificando solo algunos campos
  User copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? password,
    bool? onlineStatus,
    DateTime? lastConnection,
    String? avatarUrl,
  }) {
    return User(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      onlineStatus: onlineStatus ?? this.onlineStatus,
      lastConnection: lastConnection ?? this.lastConnection,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
