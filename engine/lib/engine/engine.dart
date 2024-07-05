import 'dart:convert';

import 'package:engine/models/game_data_model.dart';
import 'package:engine/models/rules_model.dart';
import 'package:flutter/material.dart';
import '../test.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'game.dart';

class Game extends StatefulWidget {
  final List<Map<String, dynamic>> gameJsonList;

  Game({Key? key, required this.gameJsonList}) : super(key: key);

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  bool loading = true;
  int currentSceneIndex = 0;
  late GameData gameData;
  GameRules gameRules = GameRules(gameRules: {});

  @override
  void initState() {
    super.initState();
    loadGameData(currentSceneIndex);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void loadGameData(int sceneIndex) {
    setState(() {
      gameData = GameData.fromJson(widget.gameJsonList, sceneIndex);
      gameRules = GameRules.fromJson(widget.gameJsonList[sceneIndex]['Game Rules']);
      loading = false;
    });
  }

  @override
  void didUpdateWidget(covariant Game oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.gameJsonList != oldWidget.gameJsonList) {
      // If the incoming data is different, update the game state accordingly
      loadGameData(currentSceneIndex);
    }
  }

  void goToNextScene() {
    if (currentSceneIndex < widget.gameJsonList.length - 1) {
      setState(() {
        currentSceneIndex++;
        loadGameData(currentSceneIndex);
      });
    }
  }

  void goToPreviousScene() {
    if (currentSceneIndex > 0) {
      setState(() {
        currentSceneIndex--;
        loadGameData(currentSceneIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Color.fromARGB(255, 216, 19, 19),
      child: loading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : AspectRatio(
              aspectRatio: 4 / 3,
              child: GameWidget<MyGame>(
                game: MyGame(
                  gamedata: gameData,
                  gameRules: gameRules,
                  context: context,
                ),
                backgroundBuilder: (context) {
                  return gameData.backgroundBuilder(context);
                },
              ),
            ),
    );
  }

  Future<String> loadJsonFromAssets(String path) async {
    return await rootBundle.loadString(path);
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    try {
      String jsonString = await loadJsonFromAssets('assets/final_game_context.json');
      List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(jsonDecode(jsonString));
      print("json");
      print(jsonString);
      print(data);

      return data;
    } catch (e) {
      setState(() {
        loading = false;
      });
      print('Error loading JSON data: $e');
      return [];
    }
  }
}
