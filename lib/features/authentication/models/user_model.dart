class UserModel {
  final String name;
  final String email;
  final String mobile;
  final String password;
  final String? uid;
  final String? imageUrls;
  final bool isBlocked;

  UserModel({
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
    this.imageUrls,
    this.uid,
    this.isBlocked = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? 'No name',
      email: json['email'] ?? 'No email',
      mobile: json['mobile'] ?? 'No mobile',
      password: json['password'] ?? '',
      imageUrls: json['imageUrls'] as String?,
      uid: json['uid'] as String?,
      isBlocked: json['isBlocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'mobile': mobile,
      'password': password,
      'imageUrls': imageUrls,
      'uid': uid,
      'isBlocked': isBlocked,
    };
  }
}
