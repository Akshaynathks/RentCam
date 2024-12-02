class UserModel {
  String name;
  String email;
  String mobile;
  String password;
  String ? uid;

  UserModel(
      {required this.name,
      required this.email,
      required this.mobile,
      required this.password,
      this.uid});
}
