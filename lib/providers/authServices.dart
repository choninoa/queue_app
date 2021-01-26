import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ke/persistence/repositories/userRepositoryFromMemory.dart';

class AuthServices with ChangeNotifier {
  UserRepositoryFromMemory currentUser;
  String usermap;
  bool loggedin;
  bool isFirstTime;
  AuthServices({this.loggedin, this.usermap, this.isFirstTime});
  Future getUser() {
    if (loggedin) {
      this.currentUser =
          new UserRepositoryFromMemory.fromJson(json.decode(usermap));
    }
    return Future.value(currentUser);
  }

  UserRepositoryFromMemory get user => currentUser;

  Future logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loggedin = false;
    this.currentUser = null;
    prefs.clear();
    notifyListeners();
    return Future.value(currentUser);
  }

  Future loginUser({String user}) {
    this.currentUser = new UserRepositoryFromMemory.fromJson(json.decode(user));
    notifyListeners();
    return Future.value(currentUser);
  }
}
