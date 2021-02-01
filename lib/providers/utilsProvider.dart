import 'package:flutter/material.dart';
import 'package:ke/utils/mapTypes.dart';

class UtilsProvider with ChangeNotifier {
  MapTypes showC = MapTypes.RED;

  MapTypes showCurrent() => showC;
  setCurrent(MapTypes newC) {
    showC = newC;
    notifyListeners();
  }
}
