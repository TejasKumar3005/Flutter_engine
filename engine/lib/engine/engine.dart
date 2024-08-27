import 'dart:convert';

import 'package:engine/controllers/player_controller.dart';
import 'package:engine/models/game_data_model.dart';
import 'package:engine/models/rules_model.dart';
import 'package:engine/utils/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';
import 'game.dart';

class Game extends StatefulWidget {
  final List<Map<String, dynamic>> gameJsonList;

  Game({Key? key, required this.gameJsonList}) : super(key: key);

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  bool loading = true;

  late List<GameData> gameData;
  GameRules gameRules = GameRules(gameRules: {});

  @override
  void initState() {
    super.initState();
    print("initState called");
    gameData = [];
  
    if (widget.gameJsonList.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider=Provider.of<GameUtilsProvider>(context, listen: false);
    loadGameData(provider.currentSceneIndex);
    });
    } else {
      print('gameJsonList is empty');
      setState(() {
        loading = false;
      });
    }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void loadGameData(int sceneIndex) {
    if (sceneIndex >= 0 && sceneIndex < widget.gameJsonList.length) {
      setState(() {
        gameData = [];

        for (var scene in widget.gameJsonList) {
          if (scene != null ) {
            gameData.add(GameData.fromJson(widget.gameJsonList, sceneIndex));
          } else {  
            print('Invalid or missing gameData for scene $sceneIndex');
           
          }
        }

        if (widget.gameJsonList[sceneIndex]['Game Rules'] != null) {
          gameRules = GameRules.fromJson(widget.gameJsonList[sceneIndex]['Game Rules']);
        } else {
          print('Invalid or missing Game Rules for scene $sceneIndex');
        }

        loading = false;
      });
    } else {
      print('Scene index $sceneIndex is out of range');
    }
  }

  @override
  void didUpdateWidget(covariant Game oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("didUpdateWidget called");
// final pro=Provider.of<GameUtilsProvider>(context, listen: false);
//     if (widget.gameJsonList != oldWidget.gameJsonList) {
//       // If the incoming data is different, update the game state accordingly
//       loadGameData(pro.currentSceneIndex);
//     }
  }

  // void goToNextScene() {
  //   if (currentSceneIndex < widget.gameJsonList.length - 1) {
  //     setState(() {
  //       currentSceneIndex++;
  //       loadGameData(currentSceneIndex);
  //     });
  //   }
  // }

  // void goToPreviousScene() {
  //   if (currentSceneIndex > 0) {
  //     setState(() {
  //       currentSceneIndex--;
  //       loadGameData(currentSceneIndex);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameUtilsProvider>(context, listen: false);
    print("game state rebuilt");
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
                    gamedataList: gameData,
                    gameRules: gameRules,
                    context: context,
                    currentSceneIndex: gameState.currentSceneIndex,
                    provider: gameState),
                backgroundBuilder: (context) {
                  return gameData[gameState.currentSceneIndex]
                      .backgroundBuilder(context);
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
      String jsonString =
          await loadJsonFromAssets('final_game_context.json');
      List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(jsonDecode(jsonString));
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
