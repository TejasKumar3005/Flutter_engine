import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../utils/dimensions.dart';
import '../test.dart';
// Engine widget that takes a JSON onject and then implements the game 

// Data structure class for the game
// widget that takes a JSON onject and then implements the game



class Game extends StatefulWidget {
  
  final String gameJson;

  Game({Key? key, required this.gameJson}) : super(key: key);

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: getVerticalSize(FIGMA_DESIGN_HEIGHT_DOUBLE),
      width: getHorizontalSize(FIGMA_DESIGN_WIDTH_DOUBLE),
      color: Color.fromARGB(255, 23, 13, 220),
      child : Stack(
      children: [ResponsiveWidgetTest()],
    )
    );
  }
}
