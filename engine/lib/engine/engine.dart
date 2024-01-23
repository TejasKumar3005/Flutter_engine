import 'package:flutter/material.dart';
import 'package:flame/game.dart';
// import '../utils/dimensions.dart';
import '../test.dart';
// Engine widget that takes a JSON onject and then implements the game 

// Data structure class for the game
// widget that takes a JSON onject and then implements the game



class Game extends GameWidget {
  
  final String gameJson;

  Game({Key? key, required this.gameJson}) : super(key: key);

  @override
  State<GameWidget> createState() => _GameState();
}