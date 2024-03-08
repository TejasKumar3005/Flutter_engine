import 'dart:convert';

import 'package:engine/models/game_data_model.dart';
import 'package:engine/models/rules_model.dart';
import 'package:flutter/material.dart';
import '../test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'game.dart';

class Game extends StatefulWidget {
  final Map<String, dynamic> gameJson;

  Game({Key? key, required this.gameJson}) : super(key: key);

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  late GameData gameData = GameData(characters: {}, variables: {});
  GameRules gameRules = GameRules(gameRules: {});

  @override
  void initState() {
    super.initState();
    fetchData().then((value) => {
          setState(() {
            gameData = GameData.fromJson(value);
            
          })
        });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (gameData == null) {
      // Handle the case where gameData is not initialized yet
      return CircularProgressIndicator(); // Or any other loading indicator
    }
    return Container(
      // Set your desired aspect ratio here
      width: 500.0,
      height: 500.0,
      color: Color.fromARGB(255, 23, 13, 220),
      child: AspectRatio(
          aspectRatio: 4 / 3, // Example aspect ratio: width / height
          child: GameWidget<MyGame>(
            game: MyGame(gamedata: gameData, gameRules: gameRules),
            backgroundBuilder: (context) {
              // Your custom widget as a background
              return gameData.background_builder(context);
            },
            // You can still use all the other properties like backgroundBuilder, overlayBuilderMap, etc.
          )),
    );
  }

  Future<String> loadJsonFromAssets(String path) async {
    return await rootBundle.loadString(path);
  }

  Future<Map<String, dynamic>> fetchData() async {
    try {
      String jsonString =
          await loadJsonFromAssets('assets/final_game_context.json');
      Map<String, dynamic> data = jsonDecode(jsonString);

      return data;
    } catch (e) {
      print('Error loading JSON data: $e');
      return {};
    }
  }
}
