import 'package:ke/persistence/models/userModel.dart';

class UserRepositoryFromMemory {
  final UserModel user;
  UserRepositoryFromMemory({this.user});

  factory UserRepositoryFromMemory.fromJson(Map<String, dynamic> json) {
    return UserRepositoryFromMemory(user: parseUser(json));
  }

  static UserModel parseUser(users) {
    UserModel finaluser = UserModel.fromMap(users);
    return finaluser;
  }
}
