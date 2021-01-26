import 'package:ke/persistence/models/userModel.dart';
import 'package:flutter/material.dart';

class CurrentUser with ChangeNotifier {
  UserModel user;

  UserModel getUser() => user;
  setUser(UserModel newuser) {
    user = newuser;
    notifyListeners();
  }
}
