import 'package:flutter/material.dart';


class GameUtilsProvider extends ChangeNotifier {
  int currentSceneIndex = 0;

  void increaseIndex() {
    currentSceneIndex++;
    notifyListeners();
  }
}
