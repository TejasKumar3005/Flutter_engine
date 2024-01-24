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
  // Map<String, VersatileImage> character_images = {};
  Map<String, Variable> variables = {};
  // Map<String, Vector2> positions = {};
  // Map<String, Vector2> sizes = {};

  Map<String, CharacterInfo> characters = {};

  GameData(
      {this.backgroundImage,
      this.character_images = const {},
      this.variables = const {}});

  factory GameData.fromJson(Map<String, dynamic> json) {
    GameData gameData = GameData();
    gameData.backgroundImage =
        VersatileImage.assetPng(json['background_image']);
    for (var character in json['characters']) {
      gameData.character_images[character['name']] =
          VersatileImage.assetPng(character['image']);
    }
    for (var variable in json['variables']) {
      gameData.variables[variable['name']] =
          Variable(variable['name'], variable['type'], variable['value']);
    }
    return gameData;
  }
}
