import 'conditional_model.dart';
import 'game_data_model.dart';
import 'variables_model.dart';

class Action {
  DataType? var1;
  DataType? var2;
  DataType? targetvar;
  String? operation; // +, -, *, inplace+, inplace*, inplace-

  factory Action.fromJson(Map<String, dynamic> json) {
    return Action.variableOperation(
      var1: initDataType(json["operand1"]),
      var2: initDataType(json["operand2"]),
      targetvar: initDataType(json["target"]),
      operation: json['operator'],
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
    if (operation != null) {
      performVariableOperation(gameData);
    }
  }

  void performVariableOperation(GameData gameData) {
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
      case '=':
        result = var1!.getValue(gameData);
        break;
      case '||':
        result = _toBoolean(var1!, gameData) || _toBoolean(var2!, gameData);
        break;
      case '&&':
        result = _toBoolean(var1!, gameData) && _toBoolean(var2!, gameData);
        break;
      case 'NOR':
        result = _toBoolean(var1!, gameData) && !_toBoolean(var2!, gameData);
        break;
      case 'update_position':
        result = var1!.getValue(gameData);
        break;
      case 'fix_pos':
        targetvar!.fixCharac(gameData);
        break;
      case 'replace':
        replaceValues(gameData);
        break;
      case 'show_text':
        gameData.shouldShowDialog = true;
        gameData.dialogMessage = var1!.getValue(gameData);
        break;
      case 'change_animation':
        if (targetvar != null && var1 != null) {
          changeAnimation(gameData, targetvar!.getValue(gameData), var1!.getValue(gameData));
        }
        break;
      default:
        throw Exception('Unsupported variable operation: $operation');
    }
    if (result != null) {
      targetvar!.setValue(gameData, result);
    }
  }

  void replaceValues(GameData gameData) {
    if (gameData.variables.containsKey(var1) &&
        gameData.variables.containsKey(var2)) {
      var temp = gameData.variables[var1]!.value;
      gameData.variables[var1]!.value = gameData.variables[var2]!.value;
      gameData.variables[var2]!.value = temp;
    }
  }

  void changeAnimation(GameData gameData, String characterName, String newGif) {
    if (gameData.characters.containsKey(characterName)) {
      print("change of animation");
      gameData.characters[characterName]!.currentGif = newGif;
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
