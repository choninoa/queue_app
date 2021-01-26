import 'package:ke/persistence/models/userModel.dart';
import 'package:flutter/material.dart';

class CurrentPositionProvider with ChangeNotifier {
  bool showC=false;

  bool showCurrent() => showC;
  setCurrent(bool newC) {
    showC = newC;
    notifyListeners();
  }
}
