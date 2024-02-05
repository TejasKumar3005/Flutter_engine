import 'package:engine/models/game_data_model.dart';

class GameRules {
  // Placeholder for trigger logic
  void trigger(GameData gameData) {
    print('Trigger activated!');
  }

  // Placeholder for conditional logic
  bool checkCondition(ConditionalOp condition, GameData gameData) {
    return condition.evaluate();
  }

  // Placeholder for rule application logic
  void applyRule(Action action, GameData gameData) {
    action.execute(gameData);
  }

  // Placeholder for applying rules based on conditions
  void applyRules(List<Action> actions, List<ConditionalOp> conditions, GameData gameData) {
    trigger(gameData); // Trigger at the beginning (customize based on your needs)

    for (int i = 0; i < actions.length; i++) {
      if (conditions.length > i && checkCondition(conditions[i], gameData)) {
        applyRule(actions[i], gameData);
      }
    }
  }
}

class Action {
  String? var1;
  String? var2;
  String? targetvar;
  String? operation; // +, -, *, inplace+, inplace*, inplace-

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
    if (gameData.variables.containsKey(var1) &&
        gameData.variables.containsKey(var2)) {
      dynamic result;
      switch (operation) {
        case '+':
          result = gameData.variables[var1]!.value +
              gameData.variables[var2]!.value;
          break;
        case '-':
          result = gameData.variables[var1]!.value -
              gameData.variables[var2]!.value;
          break;
        case '*':
          result = gameData.variables[var1]!.value *
              gameData.variables[var2]!.value;
          break;
        case '+=':
          gameData.variables[var1]!.value +=
              gameData.variables[var2]!.value;
          break;
        case '-=':
          gameData.variables[var1]!.value -=
              gameData.variables[var2]!.value;
          break;
        case '*=':
          gameData.variables[var1]!.value *=
              gameData.variables[var2]!.value;
          break;
        case 'OR':
          result = _toBoolean(gameData.variables[var1]!) ||
              _toBoolean(gameData.variables[var2]!);
          break;
        case 'AND':
          result = _toBoolean(gameData.variables[var1]!) &&
              _toBoolean(gameData.variables[var2]!);
          break;
        case 'NOR':
          result = _toBoolean(gameData.variables[var1]!) &&
              !_toBoolean(gameData.variables[var2]!);
          break;
        case 'string':
          result = '${gameData.variables[var1]!.value}${gameData.variables[var2]!.value}';
          break;
        case 'replace':
          replaceValues(gameData);
          break;
        default:
          throw Exception('Unsupported variable operation: $operation');
      }
      if (result != null) {
        gameData.variables[targetvar]!.value = result;
      }
    }
  }

  void replaceValues(GameData gameData) {
    if (gameData.variables.containsKey(var1) &&
        gameData.variables.containsKey(var2)) {
      gameData.variables[var1]!.value =
          gameData.variables[var2]!.value;
    }
  }

  bool _toBoolean(Variable variable) {
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
        return false;
    }
  }
}

  bool _toBoolean(Variable variable) {
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
        return false;
    }
  }

