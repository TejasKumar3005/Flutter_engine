import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class Variable {
  String name;
  String type;
  dynamic value;

  Variable({
    required this.name,
    required this.type,
    required this.value,
  });

  dynamic getValue(GameData gameData) {
    return value;
  }

  void setValue(GameData gameData, dynamic newValue) {
    value = newValue;
  }

  factory Variable.fromJson(Map<String, dynamic> json) {
    return Variable(
      name: json['name'],
      type: json['type'],
      value: json['value'],
    );
  }

  @override
  String toString() {
    return 'Variable(name: $name, type: $type, value: $value)';
  }
}

class CharacterInfo {
  String image;
  Vector2 position;
  Vector2 size;
  bool isMovable;
  String name;
  final Map<String, String> gifs;  // List to store multiple GIFs
  String currentGif;
  bool isVisible; // Field to store the current GIF

  CharacterInfo({
    required this.image,
    required this.position,
    required this.size,
    required this.isMovable,
    required this.name,
    required this.gifs,
    required this.currentGif,
    this.isVisible = true, // Initialize the current GIF
  });

 @override
  String toString() {
    // Update to handle Map structure for gifs
    String gifsString = gifs.entries.map((entry) => '${entry.key}: ${entry.value}').join(', ');
    return 'Name: $name, Position: $position, Size: $size, IsMovable: $isMovable, Image: $image, GIFs: {$gifsString}, Current GIF: $currentGif';
  }

  factory CharacterInfo.fromJson(Map<String, dynamic> json) {
    // Update to handle Map structure for gifs
    Map<String, String> gifs = Map<String, String>.from(json['gifs']);
    return CharacterInfo(
      image: json['image'],
      position: Vector2(json['position']['x'].toDouble(), json['position']['y'].toDouble()),
      size: Vector2(json['size']['width'].toDouble(), json['size']['height'].toDouble()),
      isMovable: json['isMovable'],
      name: json['name'],
      gifs: gifs,
      currentGif: json['currentGif'],
    );
  }
}

class GameData {
  late String backgroundImage;
  late Map<String, Variable> variables;
  late Map<String, CharacterInfo> characters;
  late bool shouldShowDialog;
  late String dialogMessage;
  late Map<String, String> imageLinks;
  late Map<String, String> gifLinks;
  late int currentSceneIndex;
  late List<Map<String, dynamic>> scenes;

  Widget backgroundBuilder(BuildContext context) {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          border:Border.all(color: Colors.black, width: 2),
          image: DecorationImage(
            image: NetworkImage(backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  GameData({
    required this.variables,
    required this.characters,
    required this.shouldShowDialog,
    required this.dialogMessage,
    required this.imageLinks,
    required this.gifLinks,
    required this.backgroundImage,
    required this.currentSceneIndex,
    required this.scenes,
  });

  factory GameData.fromJson(List<Map<String, dynamic>> jsonList, int sceneIndex) {
    Map<String, Variable> variables = {};
    Map<String, CharacterInfo> characters = {};
    Map<String, String> imageLinks = {};
    Map<String, String> gifLinks = {};

    // Select the JSON object for the current scene index
    Map<String, dynamic> currentSceneJson = jsonList[sceneIndex];

    currentSceneJson['Images'].forEach((key, value) {
      imageLinks[key] = value;
    });
    currentSceneJson['gifs'].forEach((key, value) {
      gifLinks[key] = value;
    });

    currentSceneJson['Game State'].forEach((value) {
      variables[value['name']] = Variable(
        name: value['name'],
        type: value['type'],
        value: value['value'],
      );
    });

    List chrs = currentSceneJson['Character'];
    chrs.forEach((value) {
    characters[value["name"]] = CharacterInfo(
    image: value["image"],
    gifs: Map<String, String>.from(value["gifs"]),  // Change here to accommodate the map structure
    currentGif: value["currentGif"],
    position: Vector2(value['position']["x"].toDouble(), value['position']['y'].toDouble()),
    size: Vector2(value['size']["width"].toDouble(), value['size']["height"].toDouble()),
    isMovable: value['isMovable'],
    name: value["name"],
  );
});

    return GameData(
      variables: variables,
      characters: characters,
      shouldShowDialog: true,
      dialogMessage: currentSceneJson['Objective'] + "\nTap on the Objects to know more about them",
      imageLinks: imageLinks,
      gifLinks: gifLinks,
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
