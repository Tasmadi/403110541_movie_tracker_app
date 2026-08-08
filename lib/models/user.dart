class User {
  int? id;
  String fullName;
  String username;
  String email;
  String? profileImagePath;
  String bio;
  String createdAt;
  String updatedAt;

  User({
    this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.profileImagePath,
    required this.bio,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromMap(
    Map<String, dynamic> map,
  ) {
    return User(
      id: map['id'],
      fullName: map['full_name'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      profileImagePath: map['profile_image_path'],
      bio: map['bio'] ?? '',
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'email': email,
      'profile_image_path': profileImagePath,
      'bio': bio,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
