// action class
import 'conditional_model.dart';
import 'game_data_model.dart';
import 'variables_model.dart';


class Action {
  DataType? var1;
  DataType? var2;
  // List<DataType> varList;
  DataType? targetvar;
  String? operation; // +, -, *, inplace+, inplace*, inplace-

  factory Action.fromJson(Map<String, dynamic> json) {


    return Action.variableOperation(
      // check if var1 and var2 are variables or not
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
    print("fgyuhvygihbjvguyhvjuygvhjmmmmmmmmmmmmm");
    print(var1);
    print(var2);
    print(operation);
    if (var1 != null && var2 != null && operation != null) {
      performVariableOperation(gameData);
    }
  }

  void performVariableOperation(GameData gameData) {
    // if (gameData.variables.containsKey(var1) &&

    print("var1: $var1");
    print("weyukdhfh");
    //     gameData.variables.containsKey(var2)) {
    dynamic result;
    switch (operation) {
      case '+':
        result = var1!.getValue(gameData) + var2!.getValue(gameData);
      print("addition done");
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
      default:
        throw Exception('Unsupported variable operation: $operation');
    }
    if (result != null) {
      print(targetvar!.getValue(gameData));
      targetvar!.setValue(gameData, result);
      print(targetvar!.getValue(gameData));
      print("result: $result"); 
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
