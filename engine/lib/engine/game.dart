import 'package:engine/engine/play_area.dart';
import 'package:engine/models/game_data_model.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import '../models/object.dart';

class MyGame extends FlameGame {
  MyGame({required this.gamedata})
      : super(
          camera: CameraComponent.withFixedResolution(
            width: 500,
            height: 500,
          ),
        );
  final GameData gamedata;
  double get width => size.x;
  double get height => size.y;
  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
   
    
    gamedata.characters.values.forEach((element) {
      world.add(Object(
          position: element.position,
          size: element.size,
          image: element.image,
          isStatic: element.isMovable,
          name: element.name));
    });
  }
}
