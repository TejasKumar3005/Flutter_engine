

import 'package:flame/game.dart';

import 'game_data_model.dart';

class DataType {
  String? type;
  dynamic value;

  DataType({this.type, this.value});

  dynamic getValue(GameData gameData) {
    // return according to type 
    switch (type) {
      case "Integer":
       print(value);
        return value;
      case "double":
        return value;
      case "String":
        return value;
      case "bool":
        return value == "true";
      case "Vector":
        return Vector2(value["x"], value["y"]);
      default:
        return value;
    }
  }

  void setValue(GameData gameData, dynamic value){

  }

  void fixCharac (GameData gameData){

  }

  @override
  String toString() {
    return 'Type: $type, Value: $value';
  }
}

class Variable extends DataType {
  String name;

  Variable({ required this.name, String? type, dynamic value} )
  :super(type: type, value: value);

  Variable.fromGameData(GameData gameData, {required this.name})
      : super(
            type: gameData.variables[name]!.type,
            value: gameData.variables[name]!.value);

  @override
  dynamic getValue(GameData gameData) {
    print(gameData.variables);
    print(name);
    return gameData.variables[name]!.value;
  }

  @override
  void setValue(GameData gameData, dynamic value) {
    gameData.variables[name]!.value = value;
  }

  @override
  toString() {
    return 'Variable: $name, type: $type, value: $value';
  }
}


class CharacPosition extends DataType {
  String name;

  CharacPosition({required this.name, String? type, dynamic value})
      : super(type: type, value: value);

  CharacPosition.fromGameData(GameData gameData, {required this.name})
      : super(
            type: "Vector",
            value: gameData.characters[name]!.position);

  @override
  dynamic getValue(GameData gameData) {
    return gameData.characters[name]!.position;
  }

  @override
  void setValue(GameData gameData, dynamic value) {
    assert (value is Vector2);
    gameData.characters[name]!.position = value;
  }

  @override
  void fixCharac (GameData gameData){
    gameData.characters[name]!.isMovable = false;
  }

  @override
  toString() {
    return 'CharacPosition: $name, type: $type, value: $value';
  }
}


DataType initDataType (dynamic json){
  switch (json["type"]){
    case ("variable") :
      return Variable(name: json["name"]);
    case ("character") :
      return CharacPosition(name: json["name"]);
    default:
      return DataType(type: json["type"], value: json["value"]);
  }
}