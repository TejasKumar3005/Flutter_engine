import 'package:engine/models/game_data_model.dart';

class GameRules {
  late Map<String, GameObjectRule> gameRules;

  GameRules({
    required this.gameRules,
  });

  factory GameRules.fromJson(Map<String, dynamic> json) {
    Map<String, GameObjectRule> gameRules = {};
    json.forEach((key, value) {
      // gameRules[key] = GameObjectRule.fromJson(value);
    });
    return GameRules(
      gameRules: gameRules,
    );
  }

  void trigger(GameData gameData) {
    print('Trigger activated!');
  }

  bool checkCondition(ConditionalOp condition, GameData gameData) {
    return condition.evaluate(gameData);
  }

  void applyRule(Action action, GameData gameData) {
    action.execute(gameData);
  }

  void onTap(String objectType, GameData gameData) {
    final rule = gameRules[objectType]?.tapWith;
    if (rule != null) {
      rule.execute(gameData);
    }
  }
 


  void applyRules(List<Action> actions, List<ConditionalOp> conditions, GameData gameData) {
    trigger(gameData);

    for (int i = 0; i < actions.length; i++) {
      if (conditions.length > i && checkCondition(conditions[i], gameData)) {
        applyRule(actions[i], gameData);
      }
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

class InteractionRule {
  final Conditional condition;
  final Action action;
  // final Map<String, ConditionAction> tapWith;

  InteractionRule({
    // required this.tapWith,
    required this.condition,
    required this.action,
  });

  void execute (GameData gameData) {
    if (condition.evaluate(gameData)) {
      action.execute(gameData);
    }
  }

  factory InteractionRule.fromJson(Map<String, dynamic> json) {
    
    return InteractionRule(
      // tapWith: tapWith,
      condition: Conditional.fromJson(json['condition']),
      action: Action.fromJson(json['action']),
    );
  }
}

// All the rules asscoiated with one object
class GameObjectRule {
  // name of object
  final String objectType;
  // map of rules for which object the collision has happened
  final Map<String, InteractionRule> collisionWith;
  //tap rule
  final InteractionRule tapWith;

  GameObjectRule({
    required this.objectType,
    required this.collisionWith,
    required this.tapWith,
  });

  factory GameObjectRule.fromJson(String name ,Map<String, dynamic> json) {
    String objectType = name;

    Map<String, dynamic> collisionRulesJson = json["collision_with"];
    Map<String, dynamic> tapRulesJson = json["tap_with"];
    InteractionRule tapWith;
    Map<String, InteractionRule> collisionWith = {};

    collisionRulesJson.forEach((key, value) {
      collisionWith[key] = InteractionRule.fromJson(value);
    });

    tapWith = InteractionRule.fromJson(tapRulesJson);

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


// action class
class Action {
  DataType? var1;
  DataType? var2;
  Variable? targetvar;
  String? operation; // +, -, *, inplace+, inplace*, inplace-

  factory Action.fromJson(Map<String, dynamic> json) {
    bool var1_isvariable =  json["var1"]["type"] == "Variable"? true : false;
    bool var2_isvariable =  json["var2"]["type"] == "Variable"? true : false;
    
    return Action.variableOperation(
      // check if var1 and var2 are variables or not
      var1: var1_isvariable ? Variable(name : json["var1"]["name"]) : DataType(type: json['var1']['type'], value: json['var1']['value']),
      var2: var2_isvariable ? Variable(name : json["var2"]["name"]) : DataType(type: json['var2']['type'], value: json['var2']['value']),
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


