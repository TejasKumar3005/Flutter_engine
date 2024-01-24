// Build Game data class to store all relevant game data

import 'package:engine/utils/Image.dart';
import 'package:flame/game.dart';

class Variable {
  String name;
  String type;
  //value can be a string, int, or double, bool or list
  dynamic value;
  Variable(this.name, this.type, this.value);
}

class CharacterInfo {
  String image;
  Vector2 position;
  Vector2 size;
  bool isStatic;

  CharacterInfo(
      {required this.image,
      required this.position,
      required this.size,
      required this.isStatic});
}

class GameData {
  VersatileImage? backgroundImage;
  Map<String, Variable> variables = {};
  Map<String, CharacterInfo> characters = {};

  GameData();

  factory GameData.fromJSON(Map<String, dynamic> json) {
    GameData gameData = GameData();
    gameData.backgroundImage = VersatileImage.assetPng(json['background_image']);
    json['variables'].forEach((key, value) {
      gameData.variables[key] = Variable(key, value['type'], value['value']);
    });
    json['characters'].forEach((key, value) {
      gameData.characters[key] = CharacterInfo(
          image: value['image'],
          position: Vector2(value['position'][0], value['position'][1]),
          size: Vector2(value['size'][0], value['size'][1]),
          isStatic: value['isStatic']);
    });
    return gameData;
  }
}
