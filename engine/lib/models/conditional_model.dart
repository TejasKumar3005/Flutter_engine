import 'game_data_model.dart';
import 'variables_model.dart';

class ConditionalOp {
  String operation;
  DataType? var1;
  DataType? var2;

  ConditionalOp(this.operation, this.var1, this.var2);

  factory ConditionalOp.fromJson(Map<String, dynamic> json) {

    return ConditionalOp.variableOperation(
      // check if var1 and var2 are variables or not
      var1: initDataType(json["operand1"]),
      var2: initDataType(json["operand2"]),
      operation: json['operator'],
    );
  }

  ConditionalOp.variableOperation({
    required this.var1,
    required this.var2,
    required this.operation,
  });

  dynamic evaluate(GameData gameData) {
    switch (operation) {
      case '=':
        return isEqual(var1!, var2!, gameData);
      case '>':
        return isGreaterThan(var1!, var2!, gameData);
      case '<':
        return isLessThan(var1!, var2!, gameData);
      case '&&':
        return and(var1!, var2!, gameData);
      case '||':
        return or(var1!, var2!, gameData);
      default:
        throw Exception('Unsupported operation: $operation');
    }
  }

  bool isEqual(DataType var1, DataType var2, GameData gameData) {
    // if (var1.type != var2.type) return false;
    print("in equal");
    print("var1: $var1");
    print("var2: $var2");
    switch (var1.type) {
      case 'String':
      case 'Integer':
      case 'Float':
      case 'Boolean':
      case 'variable':
        return var1.getValue(gameData) == var2.getValue(gameData);
      case 'List':
        return _listEquals(var1.getValue(gameData), var2.getValue(gameData));
      default:
        return var1.getValue(gameData) == var2.getValue(gameData);
    }
  }

  bool isGreaterThan(DataType var1, DataType var2, GameData gameData) {
    // if (var1.type != var2.type) return false;

    switch (var1.type) {
      case 'Integer':
      case 'Float':
      case null:
      case 'variable':
        return var1.getValue(gameData) > var2.getValue(gameData);
      default:
        throw Exception('Comparison not supported for type ${var1.type}');
    }
  }

  bool isLessThan(DataType var1, DataType var2, GameData gameData) {
    // if (var1.type != var2.type) return false;

    switch (var1.type) {
      case 'Integer':
      case 'Float':
      case 'variable':
      case null:
        return var1.getValue(gameData) < var2.getValue(gameData);
      default:
        throw Exception('Comparison not supported for type ${var1.type}');
    }
  }

  bool _listEquals(List<dynamic> list1, List<dynamic> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  bool and(DataType var1, DataType var2, GameData gameData) {
    return _toBoolean(var1, gameData) && _toBoolean(var2, gameData);
  }

  bool or(DataType var1, DataType var2, GameData gameData) {
    return _toBoolean(var1, gameData) || _toBoolean(var2, gameData);
  }

  bool _toBoolean(DataType variable, GameData gameData) {
    switch (variable.type) {
      case 'Boolean':
        return variable.getValue(gameData);
      case 'Integer':
      case 'Float':
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

class Conditional {
  List<List<ConditionalOp>> operations;
//   List<ConditionalOp> operations;
  Conditional(this.operations);

  bool evaluate(GameData gameData) {
    List<bool> result = [];
    bool check = true;
    print(operations.length);
    for (int i = 0; i < operations.length; i++) {
      result.add(false);
      for (ConditionalOp op in operations[i]) {
        result[i] = result[i] || op.evaluate(gameData);
      }
    }
    for (int i = 0; i < result.length; i++) {
      check = check && result[i];
    }
    return check;
  }

  factory Conditional.fromJson(List<dynamic> json) {
    List<List<ConditionalOp>> operations = [];
    print("con--" + json.toString());
    print("length" + json.length.toString());
    for (var i = 0; i < json.length; i++) {
      List<ConditionalOp> ops = [];
      print("---json[i]");
      if (json[i] == null) {
        continue;
      }
      for (var j = 0; j < json[i]!.length; j++) {
        ops.add(ConditionalOp.fromJson(json[i][j]));
      }
      operations.add(ops);
    }
    return Conditional(operations);
  }
}
