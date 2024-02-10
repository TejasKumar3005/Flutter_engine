import 'package:engine/models/game_data_model.dart';
import 'package:flame/game.dart';
import '../models/object.dart';

class MyGame extends FlameGame {
  MyGame({required this.gamedata});
  final GameData gamedata;
  @override
  Future<void> onLoad() async {
    gamedata.characters.values.forEach((element) {world.add(Object(position: element.position,size:element.size ,image:element.image ,isStatic:element.isStatic ));});
  }
}
