

import 'game_data_model.dart';

class DataType {
  String? type;
  dynamic value;

  DataType({this.type, this.value});

  dynamic getValue(GameData gameData) {
    return value;
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

  void setValue(GameData gameData, dynamic value) {
    gameData.variables[name]!.value = value;
  }

  @override
  toString() {
    return 'Variable: $name, type: $type, value: $value';
  }
}
