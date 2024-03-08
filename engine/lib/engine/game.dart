import 'package:engine/engine/play_area.dart';
import 'package:engine/models/game_data_model.dart';
import 'package:engine/models/rules_model.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import '../models/object.dart';

class MyGame extends FlameGame  with HasCollisionDetection{
  MyGame({required this.gamedata, required this.gameRules})
      : super(
          camera: CameraComponent.withFixedResolution(
            width: 1200,
            height: 900,
          ),
        );
  final GameData gamedata;
  final GameRules gameRules;
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
