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

  CharacterInfo({
    required this.image,
    required this.position,
    required this.size,
    required this.isMovable,
    required this.name,
  });

  @override
  String toString() {
    return 'Name: $name, Position: $position, Size: $size, IsMovable: $isMovable, Image: $image';
  }
}

class GameData {
  late String backgroundImage;
  late Map<String, Variable> variables;
  late Map<String, CharacterInfo> characters;
  late bool shouldShowDialog;
  late String dialogMessage;
  late Map<String, String> imageLinks;
  late int currentSceneIndex;
  late List<Map<String, dynamic>> scenes;

  Widget backgroundBuilder(BuildContext context) {
    return Center(
        child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(backgroundImage),
                      fit: BoxFit.fitHeight)),
            )));
  }

  GameData({
    required this.variables,
    required this.characters,
    required this.shouldShowDialog,
    required this.dialogMessage,
    required this.imageLinks,
    required this.backgroundImage,
    required this.currentSceneIndex,
    required this.scenes,
  });

  factory GameData.fromJson(List<Map<String, dynamic>> jsonList, int sceneIndex) {
    Map<String, Variable> variables = {};
    Map<String, CharacterInfo> characters = {};
    Map<String, String> imageLinks = {};

    // Select the JSON object for the current scene index
    Map<String, dynamic> currentSceneJson = jsonList[sceneIndex];

    currentSceneJson['Images'].forEach((key, value) {
      imageLinks[key] = value;
    });

    print("game state");
    print(currentSceneJson['Game State']);
    currentSceneJson['Game State'].forEach((value) {
      print("processing game state");
      variables[value['name']] = Variable(
        name: value['name'],
        type: value['type'],
        value: value['value'],
      );
    });

    List chrs = currentSceneJson['Character'];
    chrs.forEach((value) {
      print(value["name"]);
      print(value["image"]);

      characters[value["name"]] = CharacterInfo(
          image: value["image"],
          position: Vector2((value['position']["x"]).toDouble(),
              value['position']['y'].toDouble()),
          size: Vector2(value['size']["width"].toDouble(),
              value['size']["height"].toDouble()),
          isMovable: value['isMovable'],
          name: value["name"]);
    });

    return GameData(
      variables: variables,
      characters: characters,
      shouldShowDialog: true,
      dialogMessage:
          currentSceneJson['Objective'] + "\nTap on the Objects to know more about them",
      imageLinks: imageLinks,
      backgroundImage: currentSceneJson['Background'],
      currentSceneIndex: sceneIndex,
      scenes: jsonList,
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
