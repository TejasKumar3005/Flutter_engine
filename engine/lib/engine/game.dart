import 'package:engine/models/game_data_model.dart';
import 'package:flame/game.dart';

class MyGame extends FlameGame {
  MyGame({required this.gamedata});
  final GameData gamedata;
  @override
  Future<void> onLoad() async {
   
  }
}
