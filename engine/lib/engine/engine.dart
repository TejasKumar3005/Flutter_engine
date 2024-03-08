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
  bool loading = true;
  late GameData gameData = GameData(characters: {}, variables: {});
  GameRules gameRules = GameRules(gameRules: {});

  @override
  void initState() {
    super.initState();
    fetchData().then((value) => {
          setState(() {
            gameData = GameData.fromJson(value);
            loading = false;
          })
        });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // if (gameData.characters == {}) {
    //   return CircularProgressIndicator(
    //     color: Colors.white,
    //   );
    // }
    return Container(
      // Set your desired aspect ratio here
      // size take the height and width of the screen
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Color.fromARGB(255, 216, 19, 19),
      child: loading?Center(child: CircularProgressIndicator(color: Colors.white,),):AspectRatio(
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
      print("json");
      print(jsonString);
      print(data);

      return data;
    } catch (e) {
      setState(() {
        loading = false;
      });
      print('Error loading JSON data: $e');
      return {};
    }
  }
}
