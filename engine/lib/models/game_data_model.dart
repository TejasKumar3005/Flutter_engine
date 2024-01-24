// Build Game data class to store all relevant game data

import 'package:engine/utils/Image.dart';
class Variable {
  String name;
  String type;
  //value can be a string, int, or double, bool or list
  dynamic value;
  Variable(this.name, this.type, this.value);
}
class GameData {
  VersatileImage? backgroundImage;
  Map<String, VersatileImage> character_images = {};
  Map<String, Variable> variables = {};

  GameData(
      {this.backgroundImage,
      this.character_images = const {},
      this.variables = const {}});


  factory GameData.fromJson(Map<String, dynamic> json) {
    GameData gameData = GameData();
    gameData.backgroundImage = VersatileImage.assetPng(json['background_image']);
    for (var character in json['characters']) {
      gameData.character_images[character['name']] = VersatileImage.assetPng(character['image']);
    }
    for (var variable in json['variables']) {
      gameData.variables[variable['name']] = Variable(variable['name'], variable['type'], variable['value']);
    }
    return gameData;
  }

  
  
}