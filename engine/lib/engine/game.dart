import 'package:engine/models/game_data_model.dart';
import 'package:flame/game.dart';
import '../models/object.dart';

class MyGame extends FlameGame {
  MyGame({required this.gamedata});
  final GameData gamedata;
  @override
  Future<void> onLoad() async {
    gamedata.character_images.keys.forEach((element) {world.add(Object(position: gamedata.positions[element],size:gamedata.sizes[element] ,image:"" ,isStatic: ,velocity: ));});
  }
}
