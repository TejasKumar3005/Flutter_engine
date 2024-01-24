import 'package:engine/models/game_data_model.dart';
import 'package:flutter/material.dart';
import '../test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'game.dart';
class Game extends StatefulWidget {
  final String gameJson;

  Game({Key? key, required this.gameJson}) : super(key: key);

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {

late GameData gameData;

  @override
  void initState() { 
  super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Set your desired aspect ratio here
      width: 200.0,
      height: 100.0,
      color: Color.fromARGB(255, 23, 13, 220),
      child: AspectRatio(
        aspectRatio: 4/3, // Example aspect ratio: width / height
        child: GameWidget<MyGame>(
          game: MyGame(gamedata: widget.gameJson),
          backgroundBuilder: (context) {
            // Your custom widget as a background
            return gameData.background_builder(context);
          },
          // You can still use all the other properties like backgroundBuilder, overlayBuilderMap, etc.
        )
      ),
    );
  }
}
