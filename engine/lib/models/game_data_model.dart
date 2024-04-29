import 'package:engine/utils/Image.dart'; // Import the necessary dependencies for images
import 'package:flame/game.dart'; // Import the necessary dependencies for game logic
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

import 'variables_model.dart'; // Import Vector2 from the vector_math library for 2D vectors



class CharacterInfo {
  String image;
  Vector2 position;
  Vector2 size;
  bool isMovable;
  String name;

  CharacterInfo(
      {required this.image,
      required this.position,
      required this.size,
      required this.isMovable,
      required this.name}
      );

  @override
  String toString() {
    return 'Name: $name, Position: $position, Size: $size, IsMovable: $isMovable, Image: $image';
  }
}

class GameData {
  late VersatileImage backgroundImage;
  late Map<String, Variable> variables;
  late Map<String, CharacterInfo> characters;
  late bool shouldShowDialog;
  late String dialogMessage;
  late Map<String, String> image_links;

  Widget background_builder(BuildContext context) {
    return 
    Center(
      child:
    AspectRatio(aspectRatio: 4 / 3, 
    child: 
    Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          image: DecorationImage(image: NetworkImage("https://svar.in/assets/img/vector3.1.png"),fit: BoxFit.fitHeight)),
    )));
  }

  GameData({
    required this.variables,
    required this.characters,
    required this.shouldShowDialog,
    required this.dialogMessage,
    required this.image_links,
  });

  factory GameData.fromJson(Map<String, dynamic> json) {
    Map<String, Variable> variables = {};
    Map<String, CharacterInfo> characters = {};
    Map<String, String> image_links = {};

    json['Images'].forEach((key, value) {
      image_links[key] = value;
    });

    print("game stateeeeeeeeeeeeeeeeeeeeeeeee");
    print(json['Game State']);
    json['Game State'].forEach( (value) {
      print("hfweiufhuwehfiuwehifuhwief");
      variables[value['name']] = Variable(
        name: value['name'],
        type: value['type'],
        value: value['value'],
      );
    });
    List chrs = json['Character'];
    chrs.forEach((value) {
      print(value["name"]);
      print(value["image"]);

      characters[value["name"]] = CharacterInfo(
          image: value["image"],
          position: Vector2((value['position']["x"]).toDouble(), value['position']['y'].toDouble()),
          size: Vector2(value['size']["width"].toDouble(), value['size']["height"].toDouble()),
          isMovable: value['isMovable'],
          name: value["name"]);
    });
   
    return GameData(
      variables: variables,
      characters: characters,
      shouldShowDialog: false,
      dialogMessage: json['Objective'],  
      image_links: image_links,
    );
  }

  @override
  String toString() {
    // Convert variables map to string
    String variablesString = 'Variables:\n';
    variables.forEach((key, value) {
      variablesString += '$key: ${value.toString()}\n';
    });

    // Convert characters map to string
    String charactersString = 'Characters:\n';
    characters.forEach((key, value) {
      charactersString += '$key: ${value.toString()}\n';
    });

    return '$variablesString\n$charactersString';
  }
}
