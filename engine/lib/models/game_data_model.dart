// Build Game data class to store all relevant game data

import 'package:engine/utils/Image.dart';
import 'package:flame/game.dart';

class DataType {
  String type;
  //value can be a string, int, or double, bool or list
  dynamic value;
  DataType(this.type, this.value);

  dynamic getValue(GameData gameData) {
    return value;
  }
}
class Variable extends DataType {
  String name;
  Variable(this.name, String type, dynamic value) : super(type, value);
  Variable.fromGameData(GameData gameData, this.name) : super(gameData.variables[name]!.type, gameData.variables[name]!.value);

  @override
  dynamic getValue(GameData gameData) {
    return gameData.variables[name]!.value;
  }

  void setValue(GameData gameData, dynamic value) {
    gameData.variables[name]!.value = value;
  }
}

class ConditionalOp {
  String operation; // Operation type (e.g., "and", "or", "isEqual", etc.)
  DataType var1;
  DataType var2;

  ConditionalOp(this.operation, this.var1, this.var2);

  dynamic evaluate() {
    switch (operation) {
      case 'isEqual':
        return isEqual(var1, var2);
      case 'isGreaterThan':
        return isGreaterThan(var1, var2);
      case 'isLessThan':
        return isLessThan(var1, var2);
      case 'and':
        return and(var1, var2);
      case 'or':
        return or(var1, var2);
      default:
        throw Exception('Unsupported operation: $operation');
    }
  }

  bool isEqual(DataType var1, DataType var2) {
    if (var1.type != var2.type) return false;

    switch (var1.type) {
      case 'String':
        return var1.value == var2.value;
      case 'int':
        return var1.value == var2.value;
      case 'double':
        return var1.value == var2.value;
      case 'bool':
        return var1.value == var2.value;
      case 'List':
        return _listEquals(var1.value, var2.value);
      default:
        return false;
    }
  }

  bool isGreaterThan(DataType var1, DataType var2) {
    if (var1.type != var2.type) return false;

    switch (var1.type) {
      case 'int':
      case 'double':
        return var1.value > var2.value;
      default:
        throw Exception('Comparison not supported for type ${var1.type}');
    }
  }

  bool isLessThan(DataType var1, DataType var2) {
    if (var1.type != var2.type) return false;

    switch (var1.type) {
      case 'int':
      case 'double':
        return var1.value < var2.value;
      default:
        throw Exception('Comparison not supported for type ${var1.type}');
    }
  }

  // Utility function for list comparison
  bool _listEquals(List<dynamic> list1, List<dynamic> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  bool and(DataType var1, DataType var2) {
    return _toBoolean(var1) && _toBoolean(var2);
  }

  bool or(DataType var1, DataType var2) {
    return _toBoolean(var1) || _toBoolean(var2);
  }

  // Convert Variable to a boolean value
  bool _toBoolean(DataType variable) {
    switch (variable.type) {
      case 'bool':
        return variable.value;
      case 'int':
      case 'double':
        return variable.value != 0;
      case 'String':
        return variable.value.isNotEmpty;
      case 'List':
        return variable.value.isNotEmpty;
      default:
        return false; // Or throw an exception depending on your preference
    }
  }

}

class Conditional {

  // have to look if nesting of variables works properly here
  List<ConditionalOp> operations;
  Conditional(this.operations);

  bool evaluate() {
    bool result = true;
    for (ConditionalOp op in operations) {
      result = result && op.evaluate();
    }
    return result;
  }
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
