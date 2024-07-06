
class GameUtilsProvider extends changeNotifier {
  int currentSceneIndex = 0;
  void increaseIndex() {
    currentSceneIndex++;
    notifyListeners();
  }
}
