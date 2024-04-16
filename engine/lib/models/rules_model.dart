import 'package:engine/models/game_data_model.dart';

import 'action_model.dart';
import 'conditional_model.dart';
import 'variables_model.dart';

class GameRules {
  late Map<String, GameObjectRule> gameRules;

  GameRules({
    required this.gameRules,
  });

  factory GameRules.fromJson(Map<String, dynamic> json) {
    print("khaali?");
    print(json);
    Map<String, GameObjectRule> gameRules = {};
    json.forEach((key, value) {
      print("wertyui");
      print(value[0]);

      gameRules[key] = GameObjectRule.fromJson(value[0]);  // TODO remove 0 in future
    });

    return GameRules(
      gameRules: gameRules,
    ); 
  }

  void trigger(GameData gameData) {
    print('Trigger activated!');
    // You might want to do something more here when trigger activates.
  }

  bool checkCondition(ConditionalOp condition, GameData gameData) {
    return condition.evaluate(gameData);
  }

  void applyRule(Action action, GameData gameData) {
    action.execute(gameData);
  }

//  void onTap(String objectType, GameData gameData) {
//   final rule = gameRules[objectType]?.tapWith;
//   if (rule != null) {
//     rule.forEach((key, value) {
//       if (checkCondition(value.condition, gameData)) {
//         applyRule(value.action, gameData);
//       }
//     });
//   } else {
//     print('No rules defined for $objectType');
//   }
// }
  void onTap(String objectType, GameData gameData) {
    final rules = gameRules[objectType]?.tapWith;
    if (rules!= null) {
      for(var rule in rules){
        rule.execute(gameData);
      }
    }
  }

  void onCollision(String objectType1, String objectType2, GameData gameData) {
    final rules = gameRules[objectType1]?.collisionWith?[objectType2] ?? null;

    if (gameRules[objectType1]?.collisionWith != null &&
        gameRules[objectType1]?.collisionWith?.containsKey(objectType2) ==
            true) {
      // Collision rule exists for objectType2
      // You can use rule here
      for( var rule in rules!){
        rule.execute(gameData);
      }
    }
  }

  void applyRules(
      List<Action> actions, List<ConditionalOp> conditions, GameData gameData) {
    trigger(gameData);

    for (int i = 0; i < actions.length; i++) {
      if (conditions.length > i && checkCondition(conditions[i], gameData)) {
        applyRule(actions[i], gameData);
      }
    }
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

  void execute(GameData gameData) {
    if (condition.evaluate(gameData)) {
      print("collision");
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

  // map of rules for which object the collision has happened
  final Map<String, List<InteractionRule>> collisionWith;
  //tap rule
  final List<InteractionRule> tapWith;

  GameObjectRule({
    required this.collisionWith,
    required this.tapWith,
  });

  factory GameObjectRule.fromJson(Map<String?, dynamic> json) {
    Map<String?, dynamic> collisionRulesJson = json["with_collision"] ?? {};
   List<Map<String, dynamic>> tapRulesJson = json["on_tap"] ?? [];
    List<InteractionRule> tapWith;
    Map<String, List<InteractionRule>> collisionWith = {};
     print("codeishere");
    collisionRulesJson.forEach((key, value) {
      collisionWith[key!] = 
          (value as List).map((e) => InteractionRule.fromJson(e)).toList();
    });
    print("collisionWith: $collisionWith");
    
    tapWith = (tapRulesJson).map((e) => InteractionRule.fromJson(e)).toList();

    print("tapWith: $tapWith");
    return GameObjectRule(
      collisionWith: collisionWith,
      tapWith: tapWith,
    );
  }

  static Map<String, InteractionRule> _parseInteractionRules(
      Map<String, dynamic> json) {
    Map<String, InteractionRule> interactionRules = {};
    json.forEach((key, value) {
      interactionRules[key] = InteractionRule.fromJson(value);
    });
    return interactionRules;
  }
}

