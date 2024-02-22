import 'package:engine/models/game_data_model.dart';

class GameRules {
  // Placeholder for trigger logic
  void trigger(GameData gameData) {
    print('Trigger activated!');
  }

  // Placeholder for conditional logic
  bool checkCondition(ConditionalOp condition, GameData gameData) {
    return condition.evaluate(gameData);
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


class ConditionAction {
  final String condition;
  final String action;

  ConditionAction({
    required this.condition,
    required this.action,
  });

  factory ConditionAction.fromJson(Map<String, dynamic> json) {
    return ConditionAction(
      condition: json['condition'],
      action: json['action'],
    );
  }
}

class InteractionRule {
  final Map<String, ConditionAction> conditionsActions;

  InteractionRule({
    required this.conditionsActions,
  });

  factory InteractionRule.fromJson(Map<String, dynamic> json) {
    Map<String, ConditionAction> conditionsActions = {};
    json.forEach((key, value) {
      conditionsActions[key] = ConditionAction.fromJson(value);
    });
    return InteractionRule(
      conditionsActions: conditionsActions,
    );
  }
}

class GameObjectRule {
  final String objectType;
  final Map<String, InteractionRule> collisionWith;
  final Map<String, InteractionRule> tapWith;

  GameObjectRule({
    required this.objectType,
    required this.collisionWith,
    required this.tapWith,
  });

  factory GameObjectRule.fromJson(Map<String, dynamic> json) {
    String objectType = json.keys.first;
    Map<String, dynamic> rulesJson = json[objectType];
    Map<String, InteractionRule> collisionWith = {};
    Map<String, InteractionRule> tapWith = {};
    rulesJson.forEach((key, value) {
      if (key == "collision_with") {
        collisionWith = _parseInteractionRules(value);
      } else if (key == "tap_with") {
        tapWith = _parseInteractionRules(value);
      }
    });
    return GameObjectRule(
      objectType: objectType,
      collisionWith: collisionWith,
      tapWith: tapWith,
    );
  }

  static Map<String, InteractionRule> _parseInteractionRules(Map<String, dynamic> json) {
    Map<String, InteractionRule> interactionRules = {};
    json.forEach((key, value) {
      interactionRules[key] = InteractionRule.fromJson(value);
    });
    return interactionRules;
  }
}


 // condition json parsing

 class ParsingCondition {
  String _expression = '';

  ParsingCondition.fromJson(Map<String, dynamic> json) {
    _expression = _parseExpression(json['condition']);
  }

  String _parseExpression(dynamic condition) {
    String result = '';

    if (condition is List) {
      if (condition.isNotEmpty) {
        result += '(';
        for (var i = 0; i < condition.length; i++) {
          if (i > 0) {
            result += ' && ';
          }
          result += _parseExpression(condition[i]);
        }
        result += ')';
      }
    } else if (condition is Map) {
      List<dynamic> operands = condition.entries.map((e) {
        String operand1 = e.value['operand1'];
        String operator = e.value['operator'];
        String operand2 = e.value['operand2'];
        return '$operand1 $operator $operand2';
      }).toList();

      result = operands.join(' || ');
    }

    return result;
  }

  String getExpression() {
    return _expression;
  }
}


// action json parsing  

class ParsingAction {
  List<String> _actions = [];

  ParsingAction.fromJson(Map<String, dynamic> json) {
    _actions = _parseActions(json['action']);
  }

  List<String> _parseActions(List<dynamic> actionList) {
    List<String> result = [];
    for (var action in actionList) {
      String target = action['target'];
      String operand1 = action['operand1'];
      String operator = action['operator'];
      String operand2 = action['operand2'];
      result.add('$target $operator $operand2');
    }
    return result;
  }

  List<String> getActions() {
    return _actions;
  }
}

// action class
class Action {
  DataType? var1;
  DataType? var2;
  Variable? targetvar;
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
          result = _toBoolean(var1!, gameData) ||
              _toBoolean(var2!, gameData);
          break;
        case 'AND':
          result = _toBoolean(var1!,gameData) &&
              _toBoolean(var2!,gameData);
          break;
        case 'NOR':
          result = _toBoolean(var1!,gameData) &&
              !_toBoolean(var2!,gameData);
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


