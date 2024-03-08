// action class
import 'conditional_model.dart';
import 'game_data_model.dart';
import 'variables_model.dart';

class Action {
  DataType? var1;
  DataType? var2;
  Variable? targetvar;
  String? operation; // +, -, *, inplace+, inplace*, inplace-

  factory Action.fromJson(Map<String, dynamic> json) {
    bool var1_isvariable = json["var1"]["type"] == "Variable" ? true : false;
    bool var2_isvariable = json["var2"]["type"] == "Variable" ? true : false;

    return Action.variableOperation(
      // check if var1 and var2 are variables or not
      var1: var1_isvariable
          ? Variable(name: json["var1"]["name"])
          : DataType(type: json['var1']['type'], value: json['var1']['value']),
      var2: var2_isvariable
          ? Variable(name: json["var2"]["name"])
          : DataType(type: json['var2']['type'], value: json['var2']['value']),
      targetvar: Variable(name: json['targetvar']['name']),
      operation: json['operation'],
    );
  }

  // Constructors for different types of actions
  Action.variableOperation({
    required this.var1,
    required this.var2,
    required this.targetvar,
    required this.operation,
  });

  void execute(GameData gameData) {
    if (var1 != null && var2 != null && operation != null) {
      performVariableOperation(gameData);
    }
  }

  void performVariableOperation(GameData gameData) {
    // if (gameData.variables.containsKey(var1) &&
    //     gameData.variables.containsKey(var2)) {
    dynamic result;
    switch (operation) {
      case '+':
        result = var1!.getValue(gameData) + var2!.getValue(gameData);
        break;
      case '-':
        result = var1!.getValue(gameData) - var2!.getValue(gameData);
        break;
      case '*':
        result = var1!.getValue(gameData) * var2!.getValue(gameData);
        break;
      // case '+=':
      //   gameData.variables[var1]!.value +=
      //       gameData.variables[var2]!.value;
      //   break;
      // case '-=':
      //   gameData.variables[var1]!.value -=
      //       gameData.variables[var2]!.value;
      //   break;
      // case '*=':
      //   gameData.variables[var1]!.value *=
      //       gameData.variables[var2]!.value;
      //   break;
      case 'OR':
        result = _toBoolean(var1!, gameData) || _toBoolean(var2!, gameData);
        break;
      case 'AND':
        result = _toBoolean(var1!, gameData) && _toBoolean(var2!, gameData);
        break;
      case 'NOR':
        result = _toBoolean(var1!, gameData) && !_toBoolean(var2!, gameData);
        break;
      case 'string':
        result =
            '${gameData.variables[var1]!.value}${gameData.variables[var2]!.value}';
        break;
      case 'replace':
        replaceValues(gameData);
        break;
      default:
        throw Exception('Unsupported variable operation: $operation');
    }
    if (result != null) {
      targetvar!.setValue(gameData, result);
    }
  }
  // }

  void replaceValues(GameData gameData) {
    if (gameData.variables.containsKey(var1) &&
        gameData.variables.containsKey(var2)) {
      // replace the values of var1 with var2 and vice versa
      var temp = gameData.variables[var1]!.value;
      gameData.variables[var1]!.value = gameData.variables[var2]!.value;
      gameData.variables[var2]!.value = temp;
    }
  }

  bool _toBoolean(DataType variable, GameData gameData) {
    switch (variable.type) {
      case 'bool':
        return variable.getValue(gameData);
      case 'int':
      case 'double':
        return variable.getValue(gameData) != 0;
      case 'String':
        return variable.getValue(gameData).isNotEmpty;
      case 'List':
        return variable.getValue(gameData).isNotEmpty;
      default:
        return false;
    }
  }
}



class ConditionAction {
  final ConditionalOp condition;
  final Action action;

  ConditionAction({
    required this.condition,
    required this.action,
  });

  factory ConditionAction.fromJson(Map<String, dynamic> json) {
    return ConditionAction(
      condition: ConditionalOp.fromJson(json['condition']),
      action: Action.fromJson(json['action']),
    );
  }
}
